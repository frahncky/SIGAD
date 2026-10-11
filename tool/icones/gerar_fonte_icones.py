"""Gera a fonte de ícones exclusiva do SIGAD.

Uso (a partir da raiz do projeto, requer `pip install fonttools skia-pathops`):

    python3 tool/icones/gerar_fonte_icones.py
    dart format lib/app/theme/sigad_icons.dart

Saídas:
- assets/fonts/SigadIcons.ttf: fonte com os glifos;
- lib/app/theme/sigad_icons.dart: constantes `SigadIcons.*` (IconData).

Linguagem visual
----------------
Cada ícone tem duas camadas, como o logotipo do aplicativo:

- traço principal (código 0xE000 + n), que segue a cor do tema;
- destaque (código 0xE000 + n + DESLOCAMENTO_DESTAQUE), pintado pelo widget
  `SigadIcon` na cor de destaque do SIGAD (laranja do logotipo).

Os traços têm 2 unidades numa grade de 24 x 24 (eixo y para baixo), com
pontas e junções arredondadas e cantos generosos. O destaque é sempre um
elemento só (a "barra do meio" do logotipo, um ponto, um preenchimento)
e nunca carrega sozinho o significado do ícone.

Para criar um ícone, adicione uma função decorada com `@icone` no FIM do
catálogo e rode o script novamente. Não mude a ordem dos ícones
existentes: o código de cada glifo depende dela.
"""

import contextlib
import math
import os
import sys

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from pathops import LineCap, LineJoin, Path, PathOp, op

GRADE = 24
UPM = 960
ESCALA = UPM / GRADE
TRACO = 2.0
PRIMEIRO_CODIGO = 0xE000
DESLOCAMENTO_DESTAQUE = 0x400


# ---------------------------------------------------------------------------
# Primitivas de desenho
# ---------------------------------------------------------------------------


def _ponto(cx, cy, r, graus):
    a = math.radians(graus)
    return cx + r * math.cos(a), cy + r * math.sin(a)


def _arco_em(path, cx, cy, r, a0, a1, mover):
    """Adiciona um arco (ângulos em graus, sentido horário na tela)."""
    partes = max(1, math.ceil(abs(a1 - a0) / 90))
    passo = (a1 - a0) / partes
    k = 4 / 3 * math.tan(math.radians(passo) / 4)
    x, y = _ponto(cx, cy, r, a0)
    if mover:
        path.moveTo(x, y)
    else:
        path.lineTo(x, y)
    for i in range(partes):
        t0 = math.radians(a0 + passo * i)
        t1 = math.radians(a0 + passo * (i + 1))
        x0, y0 = cx + r * math.cos(t0), cy + r * math.sin(t0)
        x1, y1 = cx + r * math.cos(t1), cy + r * math.sin(t1)
        path.cubicTo(
            x0 - k * r * math.sin(t0),
            y0 + k * r * math.cos(t0),
            x1 + k * r * math.sin(t1),
            y1 - k * r * math.cos(t1),
            x1,
            y1,
        )


def _contorno(comandos):
    """Constrói um Path a partir de comandos no estilo SVG (absolutos).

    Comandos: ("M", x, y), ("L", x, y), ("Q", x1, y1, x, y),
    ("C", x1, y1, x2, y2, x, y), ("A", cx, cy, r, a0, a1), ("Z",).
    """
    p = Path()
    aberto = False
    for c in comandos:
        tipo = c[0]
        if tipo == "M":
            p.moveTo(*c[1:])
            aberto = True
        elif tipo == "L":
            p.lineTo(*c[1:])
        elif tipo == "Q":
            p.quadTo(*c[1:])
        elif tipo == "C":
            p.cubicTo(*c[1:])
        elif tipo == "A":
            _arco_em(p, *c[1:], mover=not aberto)
            aberto = True
        elif tipo == "Z":
            p.close()
            aberto = False
    return p


def _arredondado(pontos, raio, fechado):
    """Polilinha com cantos arredondados. Cada ponto pode ser (x, y, r)."""
    pts = [(p[0], p[1], p[2] if len(p) > 2 else raio) for p in pontos]
    n = len(pts)
    cmds = []
    for i, (x, y, r) in enumerate(pts):
        canto = fechado or 0 < i < n - 1
        if not canto or r <= 0:
            cmds.append(("M" if not cmds else "L", x, y))
            continue
        ax, ay = pts[i - 1][:2]
        bx, by = pts[(i + 1) % n][:2]
        da = math.hypot(ax - x, ay - y)
        db = math.hypot(bx - x, by - y)
        d = min(r, da / 2, db / 2)
        p1 = (x + (ax - x) / da * d, y + (ay - y) / da * d)
        p2 = (x + (bx - x) / db * d, y + (by - y) / db * d)
        cmds.append(("M" if not cmds else "L", *p1))
        cmds.append(("Q", x, y, *p2))
    if fechado:
        cmds.append(("Z",))
    return _contorno(cmds)


def _tracar(path, largura=TRACO):
    path.stroke(largura, LineCap.ROUND_CAP, LineJoin.ROUND_JOIN, 4)
    path.convertConicsToQuads()
    return path


def _ret(x, y, w, h, r):
    return _arredondado([(x, y), (x + w, y), (x + w, y + h), (x, y + h)], r, True)


def _circ(cx, cy, r):
    p = Path()
    _arco_em(p, cx, cy, r, 0, 360, mover=True)
    p.close()
    return p


class Glifo:
    """Acumula formas em duas camadas: traço principal e destaque.

    Por padrão tudo vai para o traço principal; use `with g.destaque():`
    para desenhar na camada de destaque.
    """

    def __init__(self):
        self.base = Path()
        self.acento = Path()
        self._no_destaque = False

    @contextlib.contextmanager
    def destaque(self):
        self._no_destaque = True
        try:
            yield
        finally:
            self._no_destaque = False

    # -- composição -------------------------------------------------------
    def _somar(self, forma):
        if self._no_destaque:
            self.acento = op(self.acento, forma, PathOp.UNION)
        else:
            self.base = op(self.base, forma, PathOp.UNION)

    def recortar(self, forma):
        """Abre espaço nas duas camadas (ex.: em volta de um selo)."""
        self.base = op(self.base, forma, PathOp.DIFFERENCE)
        self.acento = op(self.acento, forma, PathOp.DIFFERENCE)

    # -- traços -----------------------------------------------------------
    def linha(self, *coords, largura=TRACO):
        pts = list(zip(coords[0::2], coords[1::2]))
        self._somar(_tracar(_arredondado(pts, 0, False), largura))

    def poli(self, pontos, raio=0, fechado=True, largura=TRACO):
        self._somar(_tracar(_arredondado(pontos, raio, fechado), largura))

    def ret(self, x, y, w, h, r=3, largura=TRACO):
        self._somar(_tracar(_ret(x, y, w, h, r), largura))

    def circulo(self, cx, cy, r, largura=TRACO):
        self._somar(_tracar(_circ(cx, cy, r), largura))

    def arco(self, cx, cy, r, a0, a1, largura=TRACO):
        p = Path()
        _arco_em(p, cx, cy, r, a0, a1, mover=True)
        self._somar(_tracar(p, largura))

    def contorno(self, *comandos, largura=TRACO):
        self._somar(_tracar(_contorno(comandos), largura))

    def ponta_seta(self, cx, cy, r, graus, tamanho=3.2):
        """Ponta de seta no fim de um arco percorrido no sentido horário."""
        x, y = _ponto(cx, cy, r, graus)
        tx, ty = -math.sin(math.radians(graus)), math.cos(math.radians(graus))
        nx, ny = -ty, tx
        self.linha(
            x - tx * tamanho + nx * tamanho,
            y - ty * tamanho + ny * tamanho,
            x,
            y,
            x - tx * tamanho - nx * tamanho,
            y - ty * tamanho - ny * tamanho,
        )

    # -- preenchimentos ---------------------------------------------------
    def ponto(self, cx, cy, r=1.3):
        self._somar(_circ(cx, cy, r))

    def preencher(self, *comandos):
        self._somar(_contorno(comandos))

    def preencher_poli(self, pontos, raio=0):
        self._somar(_arredondado(pontos, raio, True))

    def preencher_ret(self, x, y, w, h, r=1):
        self._somar(_ret(x, y, w, h, r))

    def recortar_ret(self, x, y, w, h, r=1):
        self.recortar(_ret(x, y, w, h, r))

    def recortar_circulo(self, cx, cy, r):
        self.recortar(_circ(cx, cy, r))

    def recortar_linha(self, *coords, largura):
        pts = list(zip(coords[0::2], coords[1::2]))
        self.recortar(_tracar(_arredondado(pts, 0, False), largura))

    def somar_path(self, path):
        self._somar(path)


# ---------------------------------------------------------------------------
# Formas reutilizadas
# ---------------------------------------------------------------------------


def calendario(g, faixa=True):
    g.ret(3.5, 5, 17, 15.5, 3.5)
    g.linha(8, 3, 8, 6.5)
    g.linha(16, 3, 16, 6.5)
    if faixa:
        with g.destaque():
            g.linha(7.5, 10, 16.5, 10)


def prancheta(g):
    g.ret(5, 4.5, 14, 16.5, 3.5)
    g.recortar_ret(8.3, 1.8, 7.4, 5.4, 2)
    with g.destaque():
        g.preencher_ret(9, 2.7, 6, 3.8, 1.9)


def documento(g):
    g.poli([(5, 3, 3), (13.5, 3, 0.5), (19, 8.5, 0.5), (19, 21, 3), (5, 21, 3)])
    with g.destaque():
        g.preencher_poli([(13.5, 3), (19, 8.5), (14.5, 8.5, 1)], raio=0.6)


def pessoa(g, cx=12, cabeca=7.8, raio=3.8, base=20.5, largura=7.5, destaque=True):
    if destaque:
        with g.destaque():
            g.ponto(cx, cabeca, raio + 0.6)
    else:
        g.circulo(cx, cabeca, raio)
    topo = cabeca + raio + 2.8
    g.contorno(
        ("M", cx - largura, base),
        ("C", cx - largura, topo + 1.5, cx - largura * 0.55, topo, cx, topo),
        ("C", cx + largura * 0.55, topo, cx + largura, topo + 1.5, cx + largura, base),
        ("Z",),
    )


def engrenagem(g, cx, cy, externo, interno, dentes=8):
    pontos = []
    meio = 360 / dentes
    for i in range(dentes):
        base = i * meio - 90
        for ang, r in (
            (base - meio * 0.32, interno),
            (base - meio * 0.18, externo),
            (base + meio * 0.18, externo),
            (base + meio * 0.32, interno),
        ):
            pontos.append((*_ponto(cx, cy, r, ang), 0.7))
    g.poli(pontos)


def balao(g):
    g.poli([(3.5, 4, 3.5), (20.5, 4, 3.5), (20.5, 16.5, 3.5), (9.5, 16.5, 0.5), (4.5, 20.5, 0.5), (3.5, 16.5, 0.5)])


def olho(g):
    g.contorno(
        ("M", 2.5, 12),
        ("C", 5, 7.3, 8.3, 5.3, 12, 5.3),
        ("C", 15.7, 5.3, 19, 7.3, 21.5, 12),
        ("C", 19, 16.7, 15.7, 18.7, 12, 18.7),
        ("C", 8.3, 18.7, 5, 16.7, 2.5, 12),
        ("Z",),
    )


def escudo(g):
    g.contorno(
        ("M", 12, 3),
        ("L", 18.6, 5.6),
        ("Q", 19.5, 6, 19.5, 7),
        ("L", 19.5, 11),
        ("C", 19.5, 15.8, 16.3, 19.6, 12, 21),
        ("C", 7.7, 19.6, 4.5, 15.8, 4.5, 11),
        ("L", 4.5, 7),
        ("Q", 4.5, 6, 5.4, 5.6),
        ("Z",),
    )


def nuvem(g):
    g.contorno(
        ("M", 7, 19),
        ("C", 4.5, 19, 2.5, 17, 2.5, 14.5),
        ("C", 2.5, 12.3, 4.1, 10.5, 6.2, 10.2),
        ("C", 7, 7.2, 9.5, 5, 12.5, 5),
        ("C", 15.9, 5, 18.6, 7.6, 18.9, 10.9),
        ("C", 20.6, 11.4, 21.5, 12.9, 21.5, 14.8),
        ("C", 21.5, 17.1, 19.7, 19, 17.5, 19),
        ("Z",),
    )


def brilho(g, cx, cy, s):
    g.preencher(
        ("M", cx, cy - s),
        ("Q", cx + s * 0.15, cy - s * 0.15, cx + s, cy),
        ("Q", cx + s * 0.15, cy + s * 0.15, cx, cy + s),
        ("Q", cx - s * 0.15, cy + s * 0.15, cx - s, cy),
        ("Q", cx - s * 0.15, cy - s * 0.15, cx, cy - s),
        ("Z",),
    )


MARCADOR = [(6, 3.5, 2.5), (18, 3.5, 2.5), (18, 20.5, 0.6), (12, 16, 0.6), (6, 20.5, 0.6)]


# ---------------------------------------------------------------------------
# Catálogo de ícones (a ordem define o código de cada glifo)
# ---------------------------------------------------------------------------

ICONES = []


def icone(descricao):
    def registrar(func):
        ICONES.append((func.__name__, descricao, func))
        return func

    return registrar


# Navegação e ações básicas -------------------------------------------------


@icone("Fechar")
def fechar(g):
    g.linha(6, 6, 18, 18)
    g.linha(18, 6, 6, 18)


@icone("Adicionar")
def adicionar(g):
    g.linha(12, 5, 12, 19)
    g.linha(5, 12, 19, 12)


@icone("Adicionar (em círculo)")
def adicionarCirculo(g):
    g.circulo(12, 12, 9)
    with g.destaque():
        g.linha(12, 8, 12, 16)
        g.linha(8, 12, 16, 12)


@icone("Confirmar")
def confirmar(g):
    g.linha(5, 12.5, 10, 17.5, 19, 7)


@icone("Concluído")
def concluido(g):
    g.circulo(12, 12, 9)
    with g.destaque():
        g.linha(8, 12.3, 11, 15.3, 16.3, 9.5)


@icone("Avançar")
def chevronDireita(g):
    g.linha(10, 6, 16, 12, 10, 18)


@icone("Voltar")
def chevronEsquerda(g):
    g.linha(14, 6, 8, 12, 14, 18)


@icone("Expandir")
def chevronBaixo(g):
    g.linha(6, 9.5, 12, 15.5, 18, 9.5)


@icone("Seta para a direita")
def setaDireita(g):
    g.linha(5, 12, 19, 12)
    g.linha(13, 6, 19, 12, 13, 18)


@icone("Seta para cima")
def setaCima(g):
    g.linha(12, 19, 12, 5)
    g.linha(6, 11, 12, 5, 18, 11)


@icone("Seta para baixo")
def setaBaixo(g):
    g.linha(12, 5, 12, 19)
    g.linha(6, 13, 12, 19, 18, 13)


@icone("Trocar")
def trocar(g):
    g.linha(4, 8, 19, 8)
    g.linha(15, 4, 19, 8, 15, 12)
    with g.destaque():
        g.linha(20, 16, 5, 16)
        g.linha(9, 12, 5, 16, 9, 20)


@icone("Buscar")
def buscar(g):
    g.circulo(10.5, 10.5, 6.5)
    with g.destaque():
        g.linha(16, 16, 20, 20, largura=3)


@icone("Busca sem resultados")
def buscarVazio(g):
    g.circulo(10.5, 10.5, 6.5)
    g.linha(8.5, 8.5, 12.5, 12.5)
    g.linha(12.5, 8.5, 8.5, 12.5)
    with g.destaque():
        g.linha(16, 16, 20, 20, largura=3)


@icone("Mais opções")
def maisOpcoes(g):
    g.ponto(12, 5.5, 1.8)
    g.ponto(12, 18.5, 1.8)
    with g.destaque():
        g.ponto(12, 12, 1.8)


@icone("Editar")
def editar(g):
    g.poli([(14.5, 5.5, 1), (18.5, 9.5, 1), (8.5, 19.5, 0), (4, 20, 0), (4.5, 15.5, 0)])
    with g.destaque():
        g.linha(12.5, 7.5, 16.5, 11.5)


@icone("Editar anotação")
def editarNota(g):
    g.linha(4, 6, 15, 6)
    g.linha(4, 10.5, 11, 10.5)
    g.linha(4, 15, 8, 15)
    with g.destaque():
        g.poli([(17, 9, 0.8), (20, 12, 0.8), (13.5, 18.5, 0), (10.5, 19, 0), (11, 16, 0)])


@icone("Excluir")
def excluir(g):
    g.poli([(9.5, 6.5), (9.5, 3.5, 1), (14.5, 3.5, 1), (14.5, 6.5)], fechado=False)
    g.poli([(6, 6.5), (7, 20.5, 2), (17, 20.5, 2), (18, 6.5)], fechado=False)
    g.linha(10, 10.5, 10, 16.5)
    g.linha(14, 10.5, 14, 16.5)
    with g.destaque():
        g.linha(4, 6.5, 20, 6.5)


@icone("Salvar")
def salvar(g):
    g.poli([(4, 4, 3), (16, 4, 0.8), (20, 8, 0.8), (20, 20, 3), (4, 20, 3)])
    g.poli([(8.5, 4), (8.5, 8, 0.8), (14, 8, 0.8), (14, 4)], fechado=False)
    with g.destaque():
        g.preencher_ret(8, 13, 8, 4, 2)


@icone("Compartilhar")
def compartilhar(g):
    g.circulo(6.5, 12, 2.5)
    g.circulo(17.5, 18.5, 2.5)
    g.linha(8.7, 10.7, 15.3, 6.8)
    g.linha(8.7, 13.3, 15.3, 17.2)
    with g.destaque():
        g.ponto(17.5, 5.5, 3.3)


@icone("Enviar")
def enviar(g):
    g.poli([(4, 4.5), (20.5, 12), (4, 19.5), (6.8, 12)], raio=1.2)
    with g.destaque():
        g.linha(6.8, 12, 12, 12)


@icone("Baixar")
def baixar(g):
    g.linha(12, 4, 12, 15)
    g.linha(7, 10.5, 12, 15.5, 17, 10.5)
    with g.destaque():
        g.linha(5, 20, 19, 20)


@icone("Download concluído")
def baixado(g):
    g.linha(6, 11.5, 10, 15.5, 18, 7)
    with g.destaque():
        g.linha(5, 20, 19, 20)


@icone("Atualizar")
def atualizar(g):
    g.arco(12, 12, 7.5, -30, 270)
    with g.destaque():
        g.ponta_seta(12, 12, 7.5, 270, tamanho=3)


@icone("Sincronização com problema")
def sincronizacaoErro(g):
    g.arco(12, 12, 8, 200, 320)
    g.ponta_seta(12, 12, 8, 320, tamanho=2.6)
    g.arco(12, 12, 8, 20, 140)
    g.ponta_seta(12, 12, 8, 140, tamanho=2.6)
    with g.destaque():
        g.linha(12, 8.5, 12, 12.3)
        g.ponto(12, 15.3, 1.3)


@icone("Nuvem / backup")
def nuvemSincronizar(g):
    nuvem(g)
    with g.destaque():
        g.linha(12, 16, 12, 10.5)
        g.linha(9.5, 13, 12, 10.5, 14.5, 13)


@icone("Abrir externamente")
def abrirExterno(g):
    g.poli(
        [(10.5, 4.5), (4.5, 4.5, 3), (4.5, 19.5, 3), (19.5, 19.5, 3), (19.5, 13.5)],
        fechado=False,
    )
    with g.destaque():
        g.linha(14, 4, 20, 4, 20, 10)
        g.linha(20, 4, 11.5, 12.5)


@icone("Deslizar")
def deslizar(g):
    g.linha(20, 8.5, 5.5, 8.5)
    g.linha(9, 5, 5.5, 8.5, 9, 12)
    with g.destaque():
        g.ponto(15.5, 16.5, 3.3)


@icone("Entrar")
def entrar(g):
    g.poli([(14, 4), (20, 4), (20, 20), (14, 20)], raio=3, fechado=False)
    with g.destaque():
        g.linha(4, 12, 14, 12)
        g.linha(10, 8, 14, 12, 10, 16)


@icone("Sair")
def sair(g):
    g.poli([(10, 4), (4, 4), (4, 20), (10, 20)], raio=3, fechado=False)
    with g.destaque():
        g.linha(10, 12, 20, 12)
        g.linha(16, 8, 20, 12, 16, 16)


# Tempo e agenda ------------------------------------------------------------


@icone("Calendário")
def calendarioIcone(g):
    calendario(g)
    g.ponto(8.5, 15, 1.2)
    g.ponto(12, 15, 1.2)
    g.ponto(15.5, 15, 1.2)


@icone("Evento")
def evento(g):
    calendario(g, faixa=False)
    g.linha(7.5, 10, 16.5, 10)
    with g.destaque():
        g.preencher_ret(12.5, 13, 4.5, 4.5, 1.4)


@icone("Evento confirmado")
def eventoConfirmado(g):
    calendario(g, faixa=False)
    g.linha(7.5, 10, 16.5, 10)
    with g.destaque():
        g.linha(8.5, 15.2, 11, 17.5, 15.5, 13)


@icone("Evento indisponível")
def eventoOcupado(g):
    calendario(g, faixa=False)
    g.linha(7.5, 10, 16.5, 10)
    with g.destaque():
        g.linha(9.5, 13, 14.5, 18)
        g.linha(14.5, 13, 9.5, 18)


@icone("Evento com anotação")
def eventoNota(g):
    calendario(g, faixa=False)
    g.linha(7.5, 10, 16.5, 10)
    with g.destaque():
        g.linha(7.5, 14, 16.5, 14)
    g.linha(7.5, 17.3, 12.5, 17.3)


@icone("Semana")
def calendarioSemana(g):
    calendario(g, faixa=False)
    g.linha(7.5, 10, 16.5, 10)
    with g.destaque():
        g.linha(9.5, 13.5, 9.5, 17)
        g.linha(14.5, 13.5, 14.5, 17)
    g.linha(12, 13.5, 12, 17)


@icone("Relógio")
def relogio(g):
    g.circulo(12, 12, 9)
    with g.destaque():
        g.linha(12, 7, 12, 12, 15.5, 14)


@icone("Cronômetro")
def cronometro(g):
    g.circulo(12, 13.5, 7.5)
    g.linha(9.5, 2.8, 14.5, 2.8)
    g.linha(18, 7, 19.5, 5.5)
    with g.destaque():
        g.linha(12, 13.5, 12, 9.5)


@icone("Tempo decorrido")
def progressoTempo(g):
    g.circulo(12, 12, 9)
    with g.destaque():
        g.preencher(("M", 12, 12), ("L", 12, 6.3), ("A", 12, 12, 5.7, -90, 30), ("Z",))


@icone("Aguardando")
def ampulheta(g):
    g.linha(6, 3.5, 18, 3.5)
    g.linha(6, 20.5, 18, 20.5)
    g.contorno(
        ("M", 7.5, 3.5), ("L", 7.5, 6), ("Q", 7.5, 9, 12, 12),
        ("Q", 16.5, 9, 16.5, 6), ("L", 16.5, 3.5),
    )
    g.contorno(
        ("M", 7.5, 20.5), ("L", 7.5, 18), ("Q", 7.5, 15, 12, 12),
        ("Q", 16.5, 15, 16.5, 18), ("L", 16.5, 20.5),
    )
    with g.destaque():
        g.preencher_poli([(9.3, 17.8), (14.7, 17.8), (12, 15.3)], raio=0.6)


@icone("Alarme")
def alarme(g):
    g.circulo(12, 13, 7.5)
    g.linha(3.5, 6, 6.5, 3.5)
    g.linha(20.5, 6, 17.5, 3.5)
    with g.destaque():
        g.linha(9, 13, 11.2, 15.2, 15, 11.2)


@icone("Amanhecer / entardecer")
def entardecer(g):
    g.linha(2.5, 18.5, 21.5, 18.5)
    g.linha(12, 6, 12, 9)
    g.linha(5, 9.5, 7, 11.5)
    g.linha(19, 9.5, 17, 11.5)
    with g.destaque():
        g.preencher(("M", 6.5, 18.5), ("A", 12, 18.5, 5.5, 180, 360), ("Z",))


@icone("Tema claro")
def sol(g):
    for i in range(8):
        a = i * 45
        g.linha(*_ponto(12, 12, 7.3, a), *_ponto(12, 12, 9.3, a))
    with g.destaque():
        g.ponto(12, 12, 4.6)


@icone("Tema escuro")
def lua(g):
    g.contorno(
        ("M", 20, 14.5),
        ("C", 18.9, 18.3, 15.5, 21, 11.5, 21),
        ("C", 6.8, 21, 3, 17.2, 3, 12.5),
        ("C", 3, 8.5, 5.7, 5.1, 9.5, 4),
        ("C", 8.9, 5.2, 8.5, 6.6, 8.5, 8),
        ("C", 8.5, 12.7, 12.3, 16.5, 17, 16.5),
        ("C", 18.1, 16.5, 19.1, 15.6, 20, 14.5),
        ("Z",),
    )
    with g.destaque():
        brilho(g, 17, 6, 3)


# Pessoas -------------------------------------------------------------------


@icone("Pessoa")
def pessoaIcone(g):
    pessoa(g)


@icone("Adicionar pessoa")
def pessoaAdicionar(g):
    pessoa(g, cx=9.5, cabeca=8, raio=3.4, base=20.5, largura=6.5, destaque=False)
    with g.destaque():
        g.linha(19, 8, 19, 14)
        g.linha(16, 11, 22, 11)


@icone("Gerenciar conta")
def contaGerenciar(g):
    pessoa(g, cx=9.5, cabeca=8, raio=3.4, base=20.5, largura=6.5, destaque=False)
    g.recortar_circulo(18, 17, 5.4)
    with g.destaque():
        engrenagem(g, 18, 17, 4, 3, dentes=6)
        g.ponto(18, 17, 1.1)


@icone("Crachá")
def cracha(g):
    g.ret(3, 6, 18, 14, 3)
    g.recortar_ret(8.5, 2, 7, 6, 2)
    g.circulo(8.5, 12, 1.8)
    g.linha(6, 16.5, 11, 16.5)
    g.linha(14, 11.5, 18, 11.5)
    g.linha(14, 15.5, 17, 15.5)
    with g.destaque():
        g.preencher_ret(9.5, 2.8, 5, 4.8, 1.8)


@icone("Grupo")
def grupo(g):
    with g.destaque():
        g.ponto(12, 8, 3.6)
    g.contorno(
        ("M", 6.5, 19.5), ("C", 6.5, 16.3, 8.8, 14.5, 12, 14.5),
        ("C", 15.2, 14.5, 17.5, 16.3, 17.5, 19.5), ("Z",),
    )
    g.circulo(5, 10, 2.2)
    g.circulo(19, 10, 2.2)
    g.contorno(("M", 2, 18.5), ("C", 2, 16.3, 3, 15.2, 4.6, 15))
    g.contorno(("M", 22, 18.5), ("C", 22, 16.3, 21, 15.2, 19.4, 15))


@icone("Professor")
def professor(g):
    g.poli([(2, 9.5), (12, 4.5), (22, 9.5), (12, 14.5)], raio=1)
    g.contorno(
        ("M", 6, 11.8), ("L", 6, 16), ("C", 6, 18, 9, 19.5, 12, 19.5),
        ("C", 15, 19.5, 18, 18, 18, 16), ("L", 18, 11.8),
    )
    with g.destaque():
        g.linha(21.5, 10.5, 21.5, 14.5)
        g.ponto(21.5, 16, 1.6)


@icone("Aula / apresentação")
def aula(g):
    g.ret(9, 3.5, 12, 9.5, 2.5)
    g.circulo(6, 11.5, 2.5)
    g.contorno(
        ("M", 2, 20.5), ("C", 2, 17.5, 3.7, 16, 6, 16),
        ("C", 8.3, 16, 10, 17.5, 10, 20.5),
    )
    with g.destaque():
        g.linha(9, 15, 13, 11)


@icone("Suporte")
def suporte(g):
    g.arco(12, 12.5, 8, 180, 360)
    g.ret(3.5, 12, 4, 6.5, 2)
    g.ret(16.5, 12, 4, 6.5, 2)
    with g.destaque():
        g.contorno(("M", 18.5, 18.5), ("C", 18.5, 20.3, 16.8, 21, 13.5, 21))


# Documentos e tarefas ------------------------------------------------------


@icone("Demanda")
def demanda(g):
    prancheta(g)
    g.linha(8.5, 11, 15.5, 11)
    g.linha(8.5, 15, 13, 15)


@icone("Demanda atrasada")
def demandaAtrasada(g):
    prancheta(g)
    g.linha(12, 9.5, 12, 13.8)
    g.ponto(12, 16.8, 1.3)


@icone("Ação pendente")
def pendente(g):
    g.ret(5, 4.5, 14, 16.5, 3.5)
    g.recortar_ret(8.3, 1.8, 7.4, 5.4, 2)
    g.ret(9, 2.7, 6, 3.8, 1.9)
    g.linha(8.5, 11, 13, 11)
    g.recortar_circulo(17, 17, 5.6)
    with g.destaque():
        g.circulo(17, 17, 4)
        g.linha(17, 15, 17, 17, 18.5, 18)


@icone("Lista de verificação")
def checklist(g):
    g.linha(12.5, 7.5, 20, 7.5)
    g.linha(12.5, 16, 20, 16)
    with g.destaque():
        g.linha(4, 7, 6, 9, 9.5, 5)
        g.linha(4, 15.5, 6, 17.5, 9.5, 13.5)


@icone("Nova tarefa")
def tarefaAdicionar(g):
    g.linha(3.5, 11.5, 7.5, 15.5, 15.5, 7.5)
    with g.destaque():
        g.linha(18.5, 13.5, 18.5, 20.5)
        g.linha(15, 17, 22, 17)


@icone("Documento")
def documentoIcone(g):
    documento(g)
    g.linha(8.5, 13, 15.5, 13)
    g.linha(8.5, 17, 15.5, 17)


@icone("Resumo")
def documentoResumo(g):
    documento(g)
    g.ponto(9, 12.5, 1.1)
    g.linha(11.5, 12.5, 15.5, 12.5)
    g.ponto(9, 16.5, 1.1)
    g.linha(11.5, 16.5, 15.5, 16.5)


@icone("Novo documento")
def documentoAdicionar(g):
    documento(g)
    g.linha(12, 11.5, 12, 18)
    g.linha(8.8, 14.8, 15.2, 14.8)


@icone("Anotação")
def nota(g):
    g.poli([(4, 4, 3), (20, 4, 3), (20, 14, 0.5), (14, 20, 0.5), (4, 20, 3)])
    g.linha(8, 8.5, 16, 8.5)
    g.linha(8, 12, 12, 12)
    with g.destaque():
        g.preencher_poli([(20, 14), (14, 20), (14, 15, 1), (15, 14, 1)], raio=0.5)


@icone("Pasta")
def pasta(g):
    g.poli([(3.5, 4.5, 2.5), (9.5, 4.5, 1), (11.5, 7, 0.5), (20.5, 7, 3), (20.5, 19.5, 3), (3.5, 19.5, 3)])
    with g.destaque():
        g.linha(7, 11, 17, 11)


@icone("Anexo")
def anexo(g):
    g.contorno(
        ("M", 16.5, 7), ("L", 16.5, 16), ("C", 16.5, 18.5, 14.5, 20.5, 12, 20.5),
        ("C", 9.5, 20.5, 7.5, 18.5, 7.5, 16), ("L", 7.5, 6),
        ("C", 7.5, 4.3, 8.8, 3, 10.5, 3), ("C", 12.2, 3, 13.5, 4.3, 13.5, 6),
        ("L", 13.5, 9),
    )
    with g.destaque():
        g.linha(13.5, 12, 13.5, 15.3)
        g.contorno(("M", 13.5, 15.5), ("C", 13.5, 16.3, 12.8, 17, 12, 17),
                   ("C", 11.2, 17, 10.5, 16.3, 10.5, 15.5), ("L", 10.5, 8))


@icone("Livro")
def livro(g):
    g.contorno(
        ("M", 12, 6.5), ("C", 10, 5, 7.5, 4.5, 3.5, 4.5), ("L", 3.5, 18),
        ("C", 7.5, 18, 10, 18.5, 12, 20), ("C", 14, 18.5, 16.5, 18, 20.5, 18),
        ("L", 20.5, 4.5), ("C", 16.5, 4.5, 14, 5, 12, 6.5), ("Z",),
    )
    with g.destaque():
        g.linha(12, 9, 12, 16.5)


@icone("Texto")
def texto(g):
    g.linha(3.5, 6, 13.5, 6)
    g.linha(8.5, 6, 8.5, 19)
    with g.destaque():
        g.linha(13.5, 12, 20.5, 12)
        g.linha(17, 12, 17, 19)


@icone("Etiqueta")
def etiqueta(g):
    g.poli([(12.5, 3.5, 1), (20.5, 3.5, 3), (20.5, 11.5, 1), (11.5, 20.5, 2), (3.5, 12.5, 2)])
    with g.destaque():
        g.ponto(16.3, 7.7, 1.8)


@icone("Marcador")
def marcadorIcone(g):
    g.poli(MARCADOR)
    with g.destaque():
        g.linha(9.5, 8, 14.5, 8)


@icone("Marcador ativo")
def marcadorPreenchido(g):
    g.poli(MARCADOR)
    with g.destaque():
        g.preencher_poli(MARCADOR)


@icone("Fixar")
def fixar(g):
    g.poli([(9, 3.5, 1), (15, 3.5, 1), (14, 10), (17.5, 13.5, 1), (6.5, 13.5, 1), (10, 10)])
    with g.destaque():
        g.linha(12, 15, 12, 21)


@icone("Bandeira")
def bandeira(g):
    g.linha(5, 21, 5, 4)
    g.poli([(5, 4.5, 0), (18.5, 4.5, 1), (15.5, 9, 1), (18.5, 13.5, 1), (5, 13.5, 0)])
    with g.destaque():
        g.preencher_poli([(5, 4.5, 0), (18.5, 4.5, 1), (15.5, 9, 1), (18.5, 13.5, 1), (5, 13.5, 0)])


# Painéis, gráficos e indicadores --------------------------------------------


@icone("Visão geral")
def painel(g):
    g.ret(3.5, 3.5, 7, 9, 2.5)
    g.ret(3.5, 15.5, 7, 5, 2.5)
    g.ret(13.5, 11.5, 7, 9, 2.5)
    with g.destaque():
        g.preencher_ret(12.5, 2.5, 9, 7, 3.2)


@icone("Personalizar painel")
def painelPersonalizar(g):
    g.ret(3.5, 3.5, 7, 7, 2.5)
    g.ret(13.5, 3.5, 7, 7, 2.5)
    g.ret(3.5, 13.5, 7, 7, 2.5)
    with g.destaque():
        g.linha(17, 13.5, 17, 20.5)
        g.linha(13.5, 17, 20.5, 17)


@icone("Quadro de tarefas")
def kanban(g):
    g.ret(3, 3.5, 18, 17, 3.5)
    g.linha(7.5, 8, 7.5, 15)
    g.linha(16.5, 8, 16.5, 16.5)
    with g.destaque():
        g.linha(12, 8, 12, 11.5)


@icone("Análise")
def analise(g):
    g.ret(3.5, 3.5, 17, 17, 3.5)
    g.linha(8, 16.5, 8, 12.5)
    g.linha(16, 16.5, 16, 10.5)
    with g.destaque():
        g.linha(12, 16.5, 12, 7.5)


@icone("Gráfico de barras")
def graficoBarras(g):
    g.linha(5.5, 20, 5.5, 12, largura=3)
    g.linha(18.5, 20, 18.5, 9, largura=3)
    with g.destaque():
        g.linha(12, 20, 12, 4.5, largura=3)


@icone("Tendência")
def tendencia(g):
    g.linha(3.5, 17, 9, 11.5, 13, 15, 20.5, 7.5)
    with g.destaque():
        g.linha(15.5, 7.5, 20.5, 7.5, 20.5, 12.5)


@icone("Monitoramento")
def monitoramento(g):
    g.ret(3, 4.5, 18, 15, 3.5)
    g.recortar_ret(1, 10.5, 4, 3, 0)
    g.recortar_ret(19, 10.5, 4, 3, 0)
    with g.destaque():
        g.linha(3, 12, 8, 12, 10, 8.5, 13, 15.5, 15, 12, 21, 12)


@icone("Meta / alvo")
def alvo(g):
    g.circulo(12, 12, 9)
    g.circulo(12, 12, 5)
    with g.destaque():
        g.ponto(12, 12, 2)


@icone("Contraste")
def contraste(g):
    g.circulo(12, 12, 9)
    with g.destaque():
        g.preencher(("M", 12, 12), ("A", 12, 12, 9, -90, 90), ("Z",))


@icone("Equilíbrio")
def balanca(g):
    g.linha(12, 4, 12, 20)
    g.linha(8, 20, 16, 20)
    g.linha(5, 7, 19, 7)
    for cx in (5, 19):
        g.linha(cx - 2.5, 13.5, cx, 7, cx + 2.5, 13.5)
    with g.destaque():
        for cx in (5, 19):
            g.preencher(
                ("M", cx - 3.3, 13.5), ("C", cx - 3.3, 15.8, cx - 1.8, 17.3, cx, 17.3),
                ("C", cx + 1.8, 17.3, cx + 3.3, 15.8, cx + 3.3, 13.5), ("Z",),
            )


@icone("Energia")
def raio(g):
    pontos = [(13.5, 3), (5.5, 13.5), (11.5, 13.5), (10.5, 21), (18.5, 10.5), (12.5, 10.5)]
    g.poli(pontos, raio=1)
    with g.destaque():
        g.preencher_poli(pontos, raio=1)


@icone("Automático")
def automatico(g):
    g.linha(4, 20, 14, 10)
    with g.destaque():
        brilho(g, 17.5, 6, 3.4)
        brilho(g, 19.8, 13.5, 2.1)
        brilho(g, 10.3, 4.5, 2.1)


# Comunicação ---------------------------------------------------------------


@icone("Avisos")
def aviso(g):
    g.poli([(4, 9.5, 2), (9, 9.5, 0.5), (16, 5.5, 1), (16, 18.5, 1), (9, 14.5, 0.5), (4, 14.5, 2)])
    g.linha(6.5, 14.5, 7.5, 19.5)
    with g.destaque():
        g.linha(19, 12, 21.5, 12)
        g.linha(18.8, 7.6, 20.8, 6.5)
        g.linha(18.8, 16.4, 20.8, 17.5)


@icone("Notificações")
def notificacao(g):
    g.contorno(
        ("M", 6, 17), ("L", 6, 11), ("C", 6, 7.7, 8.7, 5, 12, 5),
        ("C", 15.3, 5, 18, 7.7, 18, 11), ("L", 18, 17),
    )
    g.linha(4.5, 17, 19.5, 17)
    g.linha(12, 3, 12, 5)
    with g.destaque():
        g.preencher(("M", 9.5, 19.5), ("L", 14.5, 19.5), ("C", 14.5, 20.9, 13.4, 22, 12, 22),
                    ("C", 10.6, 22, 9.5, 20.9, 9.5, 19.5), ("Z",))


@icone("Conversas")
def conversa(g):
    g.poli([(3, 4, 3), (15, 4, 3), (15, 13, 3), (7, 13, 0.5), (3, 16.5, 0.5)])
    with g.destaque():
        g.poli([(18, 8.5), (21, 8.5, 2.5), (21, 20.5, 0.5), (17.5, 17, 0.5), (10, 17, 2.5), (10, 15.5)],
               fechado=False)


@icone("Mensagem")
def mensagem(g):
    balao(g)
    with g.destaque():
        for x in (8, 12, 16):
            g.ponto(x, 10.2, 1.3)


@icone("Novo comentário")
def comentarioAdicionar(g):
    balao(g)
    with g.destaque():
        g.linha(12, 7, 12, 13.5)
        g.linha(8.8, 10.2, 15.2, 10.2)


@icone("E-mail")
def email(g):
    g.ret(3, 5, 18, 14, 3.5)
    with g.destaque():
        g.linha(6.5, 9, 12, 13, 17.5, 9)


@icone("Arroba")
def arroba(g):
    g.contorno(
        ("M", 15.5, 8.5), ("L", 15.5, 13.5), ("C", 15.5, 15.5, 16.8, 16.5, 18.2, 16.5),
        ("C", 19.8, 16.5, 21, 15, 21, 12), ("C", 21, 7, 17, 3, 12, 3),
        ("C", 7, 3, 3, 7, 3, 12), ("C", 3, 17, 7, 21, 12, 21),
        ("C", 14, 21, 15.6, 20.5, 17, 19.5),
    )
    with g.destaque():
        g.circulo(12, 12, 3.5)


@icone("Idioma")
def idioma(g):
    g.linha(3, 6, 13, 6)
    g.linha(8, 3.5, 8, 6)
    g.contorno(("M", 11, 6), ("C", 10.5, 9.5, 8, 13, 4, 15))
    g.contorno(("M", 6.5, 9.5), ("C", 8, 12, 10, 13.5, 12.5, 14.5))
    with g.destaque():
        g.linha(13, 21, 17, 11, 21, 21)
        g.linha(14.3, 18, 19.7, 18)


@icone("Globo / web")
def globo(g):
    g.circulo(12, 12, 9)
    g.linha(3, 12, 21, 12)
    with g.destaque():
        g.contorno(
            ("M", 12, 3), ("C", 9.3, 5.5, 8, 8.7, 8, 12), ("C", 8, 15.3, 9.3, 18.5, 12, 21),
            ("C", 14.7, 18.5, 16, 15.3, 16, 12), ("C", 16, 8.7, 14.7, 5.5, 12, 3), ("Z",),
        )


# Estados e alertas -----------------------------------------------------------


@icone("Atenção")
def alerta(g):
    g.poli([(12, 3.5), (21.5, 20), (2.5, 20)], raio=3)
    with g.destaque():
        g.linha(12, 9.5, 12, 14)
        g.ponto(12, 17, 1.35)


@icone("Erro")
def erro(g):
    g.circulo(12, 12, 9)
    with g.destaque():
        g.linha(12, 7.5, 12, 13)
        g.ponto(12, 16.3, 1.35)


@icone("Informação")
def info(g):
    g.circulo(12, 12, 9)
    with g.destaque():
        g.linha(12, 11, 12, 16.5)
        g.ponto(12, 7.8, 1.35)


@icone("Ajuda")
def ajuda(g):
    g.circulo(12, 12, 9)
    with g.destaque():
        g.contorno(
            ("M", 9.5, 9.5), ("C", 9.5, 8, 10.6, 7, 12, 7), ("C", 13.5, 7, 14.6, 8, 14.6, 9.4),
            ("C", 14.6, 11.5, 12, 11.6, 12, 13.6),
        )
        g.ponto(12, 16.8, 1.35)


@icone("Prioridade")
def prioridade(g):
    g.linha(12, 4, 12, 14.5, largura=2.6)
    with g.destaque():
        g.ponto(12, 19.5, 1.9)


@icone("Caixa de entrada")
def caixaEntrada(g):
    g.ret(3.5, 4, 17, 16, 3.5)
    with g.destaque():
        g.poli([(3.5, 13.5), (8.5, 13.5, 0.5), (9.5, 16, 0.5), (14.5, 16, 0.5), (15.5, 13.5, 0.5), (20.5, 13.5)],
               fechado=False)


@icone("Problema técnico")
def bug(g):
    g.ret(7, 8, 10, 13, 5)
    g.linha(3.5, 11.5, 7, 12.5)
    g.linha(20.5, 11.5, 17, 12.5)
    g.linha(3.5, 16.5, 7, 15.8)
    g.linha(20.5, 16.5, 17, 15.8)
    g.linha(12, 11.5, 12, 20)
    with g.destaque():
        g.preencher(("M", 8.6, 8), ("C", 8.6, 6.1, 10.1, 4.6, 12, 4.6), ("C", 13.9, 4.6, 15.4, 6.1, 15.4, 8), ("Z",))
        g.linha(9.5, 5.5, 8, 3.2)
        g.linha(14.5, 5.5, 16, 3.2)


# Segurança ------------------------------------------------------------------


@icone("Segurança")
def escudoIcone(g):
    escudo(g)
    with g.destaque():
        g.linha(12, 8, 12, 16)


@icone("Usuário verificado")
def escudoVerificado(g):
    escudo(g)
    with g.destaque():
        g.linha(8.8, 12, 11.2, 14.4, 15.5, 10)


@icone("Cadeado")
def cadeado(g):
    g.ret(5, 10.5, 14, 10.5, 3)
    g.contorno(
        ("M", 8, 10.5), ("L", 8, 7.5), ("C", 8, 5.3, 9.8, 3.5, 12, 3.5),
        ("C", 14.2, 3.5, 16, 5.3, 16, 7.5), ("L", 16, 10.5),
    )
    with g.destaque():
        g.ponto(12, 15, 1.6)
        g.linha(12, 15, 12, 17.5)


@icone("Biometria")
def biometria(g):
    g.arco(12, 12, 8.5, 205, 335)
    g.contorno(("M", 6.5, 16.5), ("L", 6.5, 13), ("A", 12, 13, 5.5, 180, 360), ("L", 17.5, 15.5))
    with g.destaque():
        g.contorno(("M", 9.5, 19.5), ("L", 9.5, 13), ("A", 12, 13, 2.5, 180, 360), ("L", 14.5, 20.5))
        g.linha(12, 13, 12, 17)


@icone("Mostrar")
def visivel(g):
    olho(g)
    with g.destaque():
        g.ponto(12, 12, 3.6)


@icone("Ocultar")
def oculto(g):
    olho(g)
    g.circulo(12, 12, 3)
    g.recortar_linha(4, 3.5, 20.5, 20, largura=5.5)
    with g.destaque():
        g.linha(4, 3.5, 20.5, 20)


# Lugares, equipamentos e configurações ------------------------------------------


@icone("Início")
def inicio(g):
    g.poli([(3.5, 10.5, 1), (12, 3.5, 1.5), (20.5, 10.5, 1), (20.5, 20.5, 3), (3.5, 20.5, 3)])
    with g.destaque():
        g.linha(9.5, 15.5, 14.5, 15.5)


@icone("Prédio / campus")
def predio(g):
    g.ret(4, 3.5, 10, 17, 2)
    g.ret(14, 9.5, 6, 11, 2)
    g.linha(2.5, 20.5, 21.5, 20.5)
    with g.destaque():
        for x, y in ((7.5, 7.5), (10.5, 7.5), (7.5, 11), (10.5, 11), (7.5, 14.5), (10.5, 14.5), (17, 13), (17, 16.5)):
            g.ponto(x, y, 1.1)


@icone("Sala")
def sala(g):
    g.linha(3.5, 20.5, 20.5, 20.5)
    g.poli([(6.5, 20.5), (6.5, 3.5), (17.5, 3.5), (17.5, 20.5)], raio=2.5, fechado=False)
    with g.destaque():
        g.ponto(14.3, 12.5, 1.5)


@icone("Local")
def local(g):
    g.contorno(
        ("M", 12, 21), ("C", 12, 21, 18.5, 14.8, 18.5, 9.8), ("C", 18.5, 6.2, 15.6, 3.3, 12, 3.3),
        ("C", 8.4, 3.3, 5.5, 6.2, 5.5, 9.8), ("C", 5.5, 14.8, 12, 21, 12, 21), ("Z",),
    )
    with g.destaque():
        g.ponto(12, 9.8, 2.7)


@icone("Laboratório")
def laboratorio(g):
    # Bancada de trabalho prático, neutra quanto à área (biologia, elétrica,
    # mecânica, robótica, física, matemática...): mesa, monitor e uma
    # engrenagem em destaque.
    g.linha(2.5, 14.5, 21.5, 14.5)
    g.linha(5, 14.5, 5, 20.5)
    g.linha(19, 14.5, 19, 20.5)
    g.ret(4, 4, 10, 7.5, 2)
    g.linha(9, 11.5, 9, 14.5)
    with g.destaque():
        pontos = []
        for k in range(6):
            base = k * 60 - 90
            for ang, r in ((base - 17, 2.9), (base - 9, 4), (base + 9, 4), (base + 17, 2.9)):
                pontos.append((*_ponto(17, 8.5, r, ang), 0.4))
        g.preencher_poli(pontos)
    g.recortar_circulo(17, 8.5, 1.3)


@icone("Equipamento")
def equipamento(g):
    g.ret(6, 6, 12, 12, 2.5)
    for v in (9.5, 14.5):
        g.linha(v, 3, v, 6)
        g.linha(v, 18, v, 21)
        g.linha(3, v, 6, v)
        g.linha(18, v, 21, v)
    with g.destaque():
        g.preencher_ret(9.2, 9.2, 5.6, 5.6, 1.4)


@icone("Dispositivos")
def dispositivos(g):
    g.ret(2.5, 4, 15, 11, 2.5)
    g.linha(9.5, 15, 9.5, 18.5)
    g.linha(6, 18.5, 12, 18.5)
    g.recortar_ret(13.8, 7.3, 9.4, 14.9, 2.5)
    with g.destaque():
        g.ret(15.5, 9, 6, 11.5, 2)


@icone("Manutenção")
def manutencao(g):
    # Silhueta da chave (cabo + cabeça com boca), traçada como contorno.
    cabo = _tracar(_arredondado([(5.5, 18.5), (13, 11)], 0, False), 4.2)
    forma = op(cabo, _circ(15, 9, 5.5), PathOp.UNION)
    boca = _arredondado([(17, 3.5), (21, 7.5), (16.6, 11.9), (12.6, 7.9)], 0.8, True)
    forma = op(forma, boca, PathOp.DIFFERENCE)
    forma.simplify()
    g.somar_path(_tracar(forma))
    with g.destaque():
        g.ponto(6.9, 17.1, 1.2)


@icone("Limpeza")
def limpeza(g):
    g.linha(14.5, 3, 14.5, 9.5)
    g.poli([(9, 13), (20, 13), (21, 20.5), (8, 20.5)], raio=1.2)
    with g.destaque():
        g.preencher_ret(8.5, 8.5, 12, 4.5, 1.6)


@icone("Configurações")
def configuracoes(g):
    engrenagem(g, 12, 12, 9.5, 7.3, dentes=8)
    with g.destaque():
        g.ponto(12, 12, 3.2)


@icone("Ajustes")
def ajustes(g):
    g.linha(4, 7, 12.5, 7)
    g.linha(17.5, 7, 20, 7)
    g.linha(4, 17, 6.5, 17)
    g.linha(11.5, 17, 20, 17)
    with g.destaque():
        g.ponto(15, 7, 2.7)
        g.ponto(9, 17, 2.7)


@icone("Filtro")
def filtro(g):
    g.linha(4, 7, 20, 7)
    g.linha(10, 17, 14, 17)
    with g.destaque():
        g.linha(7, 12, 17, 12)


@icone("Paleta de cores")
def paleta(g):
    g.contorno(
        ("M", 12, 3), ("C", 7, 3, 3, 7, 3, 12), ("C", 3, 17, 7, 21, 12, 21),
        ("C", 13.2, 21, 13.8, 20.2, 13.8, 19.2), ("C", 13.8, 18.2, 13.2, 17.8, 13.2, 16.8),
        ("C", 13.2, 15.8, 14, 15, 15, 15), ("L", 17, 15), ("C", 19.2, 15, 21, 13.2, 21, 11),
        ("C", 21, 6.6, 17, 3, 12, 3), ("Z",),
    )
    g.ponto(7.5, 11.5, 1.4)
    g.ponto(17, 11, 1.4)
    with g.destaque():
        g.ponto(9.5, 7.5, 1.6)
        g.ponto(14.5, 7.5, 1.6)


@icone("Menu (as três barras do logotipo)")
def menu(g):
    g.linha(4, 6.5, 20, 6.5)
    g.linha(4, 17.5, 20, 17.5)
    with g.destaque():
        g.linha(4, 12, 20, 12)


# ---------------------------------------------------------------------------
# Geração
# ---------------------------------------------------------------------------


def _nome_dart(nome):
    return nome[: -len("Icone")] if nome.endswith("Icone") else nome


def _glifo_tt(path):
    path.simplify(clockwise=False)
    caneta = TTGlyphPen(None)
    path.draw(
        TransformPen(
            Cu2QuPen(caneta, 0.5, reverse_direction=False),
            (ESCALA, 0, 0, -ESCALA, 0, UPM),
        )
    )
    return caneta.glyph()


def gerar(raiz):
    nomes_glifos = [".notdef"]
    glifos = {".notdef": TTGlyphPen(None).glyph()}
    cmap = {}
    metricas = {".notdef": (UPM, 0)}
    entradas = []

    def adicionar_glifo(codigo, path):
        nome_glifo = f"uni{codigo:04X}"
        nomes_glifos.append(nome_glifo)
        glifo = _glifo_tt(path)
        glifos[nome_glifo] = glifo
        # A margem esquerda (lsb) precisa coincidir com o xMin do contorno;
        # caso contrário, o FreeType desloca o glifo horizontalmente.
        x_min = min((x for x, _ in glifo.coordinates), default=0)
        metricas[nome_glifo] = (UPM, x_min)
        cmap[codigo] = nome_glifo

    for i, (nome, descricao, func) in enumerate(ICONES):
        g = Glifo()
        func(g)
        codigo = PRIMEIRO_CODIGO + i
        tem_destaque = len(list(g.acento.contours)) > 0
        base = g.base
        if tem_destaque:
            # O destaque fica por cima: tira a área dele do traço principal
            # para não haver sobreposição de cores nas bordas.
            base = op(base, g.acento, PathOp.DIFFERENCE)
            adicionar_glifo(codigo + DESLOCAMENTO_DESTAQUE, g.acento)
        adicionar_glifo(codigo, base)
        entradas.append((_nome_dart(nome), descricao, codigo, tem_destaque))

    fb = FontBuilder(UPM, isTTF=True)
    fb.setupGlyphOrder(nomes_glifos)
    fb.setupCharacterMap(cmap)
    fb.setupGlyf(glifos)
    fb.setupHorizontalMetrics(metricas)
    fb.setupHorizontalHeader(ascent=UPM, descent=0)
    fb.setupNameTable({"familyName": "SigadIcons", "styleName": "Regular"})
    fb.setupOS2(sTypoAscender=UPM, sTypoDescender=0, usWinAscent=UPM, usWinDescent=0)
    fb.setupPost()
    os.makedirs(os.path.join(raiz, "assets/fonts"), exist_ok=True)
    fb.save(os.path.join(raiz, "assets/fonts/SigadIcons.ttf"))

    com_destaque = [codigo for _, _, codigo, tem in entradas if tem]
    linhas = [
        "// GERADO AUTOMATICAMENTE por tool/icones/gerar_fonte_icones.py.",
        "// Não edite à mão: altere o script e gere novamente.",
        "",
        "import 'package:flutter/widgets.dart';",
        "",
        "/// Ícones exclusivos do SIGAD (fonte `SigadIcons`).",
        "///",
        "/// Cada ícone tem um traço principal e, na maioria, um destaque na cor",
        "/// do logotipo. Use com o widget `SigadIcon`, que desenha as duas",
        "/// camadas: `SigadIcon(SigadIcons.laboratorio)`.",
        "abstract final class SigadIcons {",
        "  static const String fontFamily = 'SigadIcons';",
        "",
        "  // Instâncias constantes, para o tree shaking de ícones do Flutter",
        "  // manter também os glifos de destaque.",
        "  static const Map<int, IconData> _destaques = {",
    ]
    linhas += [
        f"    0x{c:04x}: IconData(0x{c + DESLOCAMENTO_DESTAQUE:04x}, fontFamily: fontFamily),"
        for c in com_destaque
    ]
    linhas += [
        "  };",
        "",
        "  /// Camada de destaque de [icon], ou `null` se ele não tiver uma.",
        "  static IconData? destaqueDe(IconData icon) {",
        "    if (icon.fontFamily != fontFamily) return null;",
        "    return _destaques[icon.codePoint];",
        "  }",
        "",
    ]
    for nome_dart, descricao, codigo, _ in entradas:
        linhas.append(f"  /// {descricao}.")
        linhas.append(
            f"  static const IconData {nome_dart} = IconData(0x{codigo:04x}, fontFamily: fontFamily);"
        )
        linhas.append("")
    linhas[-1] = "}"
    linhas.append("")
    with open(os.path.join(raiz, "lib/app/theme/sigad_icons.dart"), "w", encoding="utf-8") as f:
        f.write("\n".join(linhas))
    return entradas


if __name__ == "__main__":
    raiz = sys.argv[1] if len(sys.argv) > 1 else "."
    entradas = gerar(raiz)
    print(f"{len(entradas)} ícones gerados ({sum(1 for e in entradas if e[3])} com destaque).")
