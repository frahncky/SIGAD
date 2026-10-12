"""Exporta ícones SigadIcons como SVG (duas cores) para a documentação.

Uso: python3 tool/icones/exportar_svg.py [destino] [nome ...]

Sem nomes, exporta os ícones usados no README.
"""

import os
import re
import sys

from fontTools.pens.svgPathPen import SVGPathPen

sys.path.insert(0, os.path.dirname(__file__))
import gerar_fonte_icones as gf  # noqa: E402

PRINCIPAL = "#087F6D"
DESTAQUE = "#F09A4A"
README = [
    "painel", "conversa", "demanda", "professor", "kanban", "laboratorio",
    "relogio", "checklist", "analise", "configuracoes", "calendarioIcone",
    "nota", "aviso", "escudoIcone", "dispositivos", "menu",
]


def _d(path):
    caneta = SVGPathPen(None)
    path.draw(caneta)
    # Duas casas decimais bastam numa grade de 24 e deixam o arquivo enxuto.
    return re.sub(r"-?\d+\.\d+", lambda m: f"{float(m.group()):.2f}".rstrip("0").rstrip("."), caneta.getCommands())


def exportar(destino, nomes):
    funcoes = {nome: func for nome, _, func in gf.ICONES}
    os.makedirs(destino, exist_ok=True)
    for nome in nomes:
        g = gf.Glifo()
        funcoes[nome](g)
        base = g.base
        if len(list(g.acento.contours)):
            base = gf.op(base, g.acento, gf.PathOp.DIFFERENCE)
        camadas = [(base, PRINCIPAL), (g.acento, DESTAQUE)]
        corpo = "".join(
            f'<path fill="{cor}" d="{_d(p)}"/>' for p, cor in camadas if len(list(p.contours))
        )
        arquivo = gf._nome_dart(nome) + ".svg"
        with open(os.path.join(destino, arquivo), "w", encoding="utf-8") as f:
            f.write(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
                f'width="48" height="48">{corpo}</svg>\n'
            )


if __name__ == "__main__":
    destino = sys.argv[1] if len(sys.argv) > 1 else "docs/readme/icones"
    exportar(destino, sys.argv[2:] or README)
