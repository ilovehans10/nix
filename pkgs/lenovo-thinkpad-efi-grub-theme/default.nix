{
  lib,
  stdenv,
  fetchFromGitHub,
  grub2,
  imagemagick,
  librsvg,
  gettext,
  # "1", "1.5", or "2" — for HD, Full HD, or hi-res displays respectively
  scaling ? "1.5",
  # "d" for dark, "l" for light
  mode ? "d",
}: let
  params = {
    "1" = {
      main = 18;
      header = 32;
      progress = 16;
      terminal = 16;
      item = 38;
      itemBorder = 2;
      bottomLine = 3;
      progressHalf = 14;
      padding = 30;
      logo = 60;
      menuWHalf = 300;
      menuHHalf = 200;
    };
    "1.5" = {
      main = 22;
      header = 42;
      progress = 20;
      terminal = 20;
      item = 48;
      itemBorder = 2;
      bottomLine = 4;
      progressHalf = 20;
      padding = 40;
      logo = 85;
      menuWHalf = 400;
      menuHHalf = 300;
    };
    "2" = {
      main = 30;
      header = 52;
      progress = 28;
      terminal = 26;
      item = 64;
      itemBorder = 3;
      bottomLine = 5;
      progressHalf = 25;
      padding = 50;
      logo = 120;
      menuWHalf = 500;
      menuHHalf = 400;
    };
  };
  p = params.${scaling};

  colors =
    if mode == "d"
    then {
      blue = "#398ecd";
      purple = "#9667cc";
      progressGray = "#ababab";
      separatorGray = "#A4A4A4";
      background = "#1c1c21";
      text = "#FFFFFF";
    }
    else {
      blue = "#1f8ee7";
      purple = "#7f629c";
      progressGray = "#BBBBBB";
      separatorGray = "#A4A4A4";
      background = "#F0F0F0";
      text = "#000000";
    };

  # Derived at Nix eval time (matches build.sh arithmetic)
  bottomLabelsOffset = p.main + p.bottomLine + p.padding;
  bottomLineOffset = p.padding + bottomLabelsOffset;
  menuWidth = p.menuWHalf * 2;
  menuHeight = p.menuHHalf * 2;
  progressBarSize = p.progressHalf * 2;
  headerOffsetMin = p.padding + p.logo;

  s = toString;
in
  stdenv.mkDerivation {
    pname = "lenovo-thinkpad-efi-grub-theme";
    version = "unstable-2024-12-23";

    src = fetchFromGitHub {
      owner = "AlexanderKh";
      repo = "lenovo-thinkpad-efi-grub-theme";
      rev = "ef7d7bc8c5edccf2c5e2de450d54fb6287bd3552";
      hash = "sha256-VbX6a7bn4U7MdpasuqX0E1ppaj7EME/ExHE4n6YVG3Y=";
    };

    nativeBuildInputs = [grub2 imagemagick librsvg gettext];

    buildPhase = ''
      set -euo pipefail

      theme_dir="$TMPDIR/lenovo-thinkpad-efi"
      icons_dir="$theme_dir/icons"
      mkdir -p "$icons_dir"

      # Generate PF2 fonts
      grub-mkfont -s ${s p.main}     -o "$theme_dir/roboto-${s p.main}.pf2"       src/fonts/roboto/Roboto-Medium.ttf
      grub-mkfont -s ${s p.header}   -o "$theme_dir/roboto-${s p.header}.pf2"     src/fonts/roboto/Roboto-Light.ttf
      grub-mkfont -s ${s p.progress} -o "$theme_dir/roboto-${s p.progress}.pf2"   src/fonts/roboto/Roboto-Regular.ttf
      grub-mkfont -s ${s p.terminal} -o "$theme_dir/terminus-ttf-${s p.terminal}.pf2" src/fonts/terminus-ttf/TerminusTTF.ttf

      # Convert logos (rsvg-convert replaces svgexport)
      rsvg-convert -h ${s p.logo} src/logos/thinkpad_logo_${mode}.svg -o "$theme_dir/thinkpad_logo.png"
      rsvg-convert -h ${s p.logo} src/logos/lenovo_logo_${mode}.svg   -o "$theme_dir/lenovo_logo.png"

      # LENOVO_LOGO_OFFSET depends on the rendered logo width — computed at build time
      LENOVO_LOGO_WIDTH=$(identify -format '%w' "$theme_dir/lenovo_logo.png")
      LENOVO_LOGO_OFFSET=$(( LENOVO_LOGO_WIDTH + ${s p.padding} ))

      # 1x1 colour PNGs (GRUB stretches them)
      convert -size 1x1 xc:"${colors.background}"   PNG32:"$theme_dir/background.png"
      convert -size 1x1 xc:"${colors.blue}"          PNG32:"$theme_dir/progress_active_c.png"
      convert -size 1x1 xc:"${colors.progressGray}"  PNG32:"$theme_dir/progress_inactive_c.png"
      convert -size 1x1 xc:"${colors.separatorGray}" PNG32:"$theme_dir/separator.png"

      # Inactive menu border pieces (transparent)
      convert -size ${s p.itemBorder}x1                         xc:transparent PNG32:"$theme_dir/menu_inactive_e.png"
      convert -size ${s p.itemBorder}x1                         xc:transparent PNG32:"$theme_dir/menu_inactive_w.png"
      convert -size 1x${s p.itemBorder}                         xc:transparent PNG32:"$theme_dir/menu_inactive_n.png"
      convert -size 1x${s p.itemBorder}                         xc:transparent PNG32:"$theme_dir/menu_inactive_s.png"
      convert -size ${s p.itemBorder}x${s p.itemBorder} xc:transparent PNG32:"$theme_dir/menu_inactive_ne.png"
      convert -size ${s p.itemBorder}x${s p.itemBorder} xc:transparent PNG32:"$theme_dir/menu_inactive_se.png"
      convert -size ${s p.itemBorder}x${s p.itemBorder} xc:transparent PNG32:"$theme_dir/menu_inactive_sw.png"
      convert -size ${s p.itemBorder}x${s p.itemBorder} xc:transparent PNG32:"$theme_dir/menu_inactive_nw.png"

      # Selected menu border pieces (blue)
      convert -size ${s p.itemBorder}x1                         xc:"${colors.blue}" PNG32:"$theme_dir/menu_selected_e.png"
      convert -size ${s p.itemBorder}x1                         xc:"${colors.blue}" PNG32:"$theme_dir/menu_selected_w.png"
      convert -size 1x${s p.itemBorder}                         xc:"${colors.blue}" PNG32:"$theme_dir/menu_selected_n.png"
      convert -size 1x${s p.itemBorder}                         xc:"${colors.blue}" PNG32:"$theme_dir/menu_selected_s.png"
      convert -size ${s p.itemBorder}x${s p.itemBorder} xc:"${colors.blue}" PNG32:"$theme_dir/menu_selected_ne.png"
      convert -size ${s p.itemBorder}x${s p.itemBorder} xc:"${colors.blue}" PNG32:"$theme_dir/menu_selected_se.png"
      convert -size ${s p.itemBorder}x${s p.itemBorder} xc:"${colors.blue}" PNG32:"$theme_dir/menu_selected_sw.png"
      convert -size ${s p.itemBorder}x${s p.itemBorder} xc:"${colors.blue}" PNG32:"$theme_dir/menu_selected_nw.png"

      # Convert icons
      for svg in src/icons/*.svg; do
        name=$(basename "$svg" .svg)
        rsvg-convert -w ${s p.item} -h ${s p.item} "$svg" -o "$icons_dir/$name.png"
      done

      # Generate theme.txt from template via envsubst
      export MAIN_FONT_SIZE="${s p.main}"
      export HEADER_FONT_SIZE="${s p.header}"
      export PROGRESS_FONT_SIZE="${s p.progress}"
      export TERMINAL_FONT_SIZE="${s p.terminal}"
      export HEADER_OFFSET_MIN="${s headerOffsetMin}"
      export BOTTOM_LABELS_POS_OFFSET="${s bottomLabelsOffset}"
      export BOTTOM_LINE_POS_OFFSET="${s bottomLineOffset}"
      export BOTTOM_LINE_SIZE="${s p.bottomLine}"
      export PADDING="${s p.padding}"
      export ITEM_SIZE="${s p.item}"
      export LENOVO_LOGO_OFFSET="$LENOVO_LOGO_OFFSET"
      export PROGRESS_BAR_SIZE="${s progressBarSize}"
      export PROGRESS_BAR_SIZE_HALF="${s p.progressHalf}"
      export MENU_WIDTH="${s menuWidth}"
      export MENU_HEIGHT="${s menuHeight}"
      export MENU_WIDTH_HALF="${s p.menuWHalf}"
      export MENU_HEIGHT_HALF="${s p.menuHHalf}"
      export LENOVO_BLUE="${colors.blue}"
      export TEXT_COLOR="${colors.text}"
      export LENOVO_PURPLE="${colors.purple}"

      envsubst < src/theme.txt.tmpl > "$theme_dir/theme.txt"
    '';

    installPhase = ''
      cp -r "$TMPDIR/lenovo-thinkpad-efi" "$out"
    '';

    meta = {
      description = "Lenovo ThinkPad EFI-inspired GRUB theme (${scaling}x, ${
        if mode == "d"
        then "dark"
        else "light"
      })";
      homepage = "https://github.com/AlexanderKh/lenovo-thinkpad-efi-grub-theme";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
    };
  }
