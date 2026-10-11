# Configuração de Ícone e Splash Screen do SIGAD

## Passos para Gerar Ícone do App

### 1. Instalar as dependências de desenvolvimento

```bash
flutter pub get
```

### 2. Gerar os ícones do app para todas as plataformas

```bash
flutter pub run flutter_launcher_icons:main -f pubspec_launcher.yaml
```

Este comando irá:
- Gerar ícones para Android (varios tamanhos)
- Gerar ícones para iOS
- Gerar ícones para macOS, Windows, Linux e Web
- Usar o arquivo `assets/images/app_icon.png` como fonte

### 3. Executar o app

```bash
flutter run
```

## Efeito ao Abrir o App

Quando o app abre, será exibida apenas a **tela de splash animada em Flutter** com:

- ✨ **Gradiente azul/roxo** como fundo
- 🔵 **Ícone circular** com o texto "SIGAD"
- 🔄 **Indicador de carregamento** (spinner)
- 💫 **Animações suaves** de fade-in e scale durante 2.5 segundos
- 🎯 **Navegação automática** para Login ou Dashboard após o splash

## Estrutura de Arquivos Criados

```
assets/
  images/
    app_icon.png          # Ícone base em PNG

lib/
  features/
    splash/
      presentation/
        pages/
          splash_page.dart # Página de splash com animações

app/
  routes/
    app_routes.dart       # Adicionado rota '/splash'
    app_router.dart       # Adicionado case para splash route
  app.dart                # Modificado initialRoute para splash

pubspec.yaml              # Dependências do projeto
pubspec_launcher.yaml     # Configuração do flutter_launcher_icons
```

## Customizações

### Mudar cores do splash screen

Edite `lib/features/splash/presentation/pages/splash_page.dart` e altere as cores do LinearGradient:

```dart
colors: [
  Color(0xFF1e40af),  // Azul - mude este valor
  Color(0xFF7c3aed),  // Roxo - mude este valor
],
```

### Mudar duração do splash screen

Edite a duração em `splash_page.dart`:

```dart
final _animationController = AnimationController(
  duration: const Duration(milliseconds: 2000), // Mude este valor
  vsync: this,
);
```

### Mudar ícone do app

Substitua `assets/images/app_icon.png` por outro arquivo PNG e execute:

```bash
flutter pub run flutter_launcher_icons:main -f pubspec_launcher.yaml
```

### Ícones de desktop (macOS e Windows)

O `flutter_launcher_icons` está configurado (em `pubspec.yaml`) para Android, iOS e Web. Os ícones de macOS e Windows são gerados a partir do mesmo arte-final, `assets/images/app_icon_full.png`, pelo script abaixo (requer Python 3 com Pillow):

```bash
python3 tool/gerar_icones_desktop.py
```

O script gera:
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_*.png` — corpo arredondado com margem e sombra, seguindo a grade de ícones do macOS;
- `windows/runner/resources/app_icon.ico` — quadrado arredondado com tamanhos de 16 a 256 px.

Execute o script sempre que o ícone principal mudar.

### Ícones das telas (SigadIcons)

As telas usam um conjunto de ícones exclusivo do SIGAD, e não os ícones Material do Flutter. A linguagem visual segue o logotipo:

- cada ícone tem duas camadas: o **traço principal**, na cor do tema, e um **destaque** na cor laranja do logotipo (`SigadColors.accent`), por exemplo a barra do meio do menu, o líquido do frasco de Laboratórios e os ponteiros do relógio;
- grade de 24 px, traço de 2 px, pontas arredondadas e cantos generosos;
- o destaque nunca carrega sozinho o significado do ícone; em estados esmaecidos (como botões desabilitados), ele acompanha a cor do traço.

Como usar:

```dart
import 'package:sigad/app/theme/sigad_icon.dart';
import 'package:sigad/app/theme/sigad_icons.dart';

const SigadIcon(SigadIcons.laboratorio)
SigadIcon(SigadIcons.relogio, color: cor, size: 20)
```

Use `SigadIcon` em vez de `Icon`: um `Icon` comum desenha só o traço principal. Os botões de menu, voltar e fechar das AppBars usam os ícones próprios via `actionIconTheme` em `app_theme.dart`.

Para criar ou alterar um ícone, edite `tool/icones/gerar_fonte_icones.py` (adicione novos ícones sempre no fim do catálogo e desenhe o destaque dentro de `with g.destaque():`) e rode:

```bash
pip install fonttools skia-pathops
python3 tool/icones/gerar_fonte_icones.py
dart format lib/app/theme/sigad_icons.dart
```

`tool/icones/mapa_material.py` registra qual ícone Material cada `SigadIcons` substituiu.

## Troubleshooting

Se os ícones não forem gerados:

1. Verifique se o arquivo PNG existe em `assets/images/app_icon.png`
2. Tente limpar o cache: `flutter clean`
3. Reinstale as dependências: `flutter pub get`
4. Tente novamente: `flutter pub run flutter_launcher_icons:main -f pubspec_launcher.yaml`

Se a splash animada não aparecer:

1. Verifique se o Flutter foi atualizado: `flutter upgrade`
2. Limpe o build: `flutter clean`
3. Execute: `flutter pub get`
4. Teste em um dispositivo real ou emulador
