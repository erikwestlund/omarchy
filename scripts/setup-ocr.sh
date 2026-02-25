#!/usr/bin/env bash

set -euo pipefail

VENV_PATH="${VENV_PATH:-$HOME/.local/share/venvs/paddleocr}"
OCRMYPDF_VENV_PATH="${OCRMYPDF_VENV_PATH:-$HOME/.local/share/venvs/ocrmypdf}"

detect_pm() {
  if command -v pacman >/dev/null 2>&1; then
    echo pacman
  elif command -v apt-get >/dev/null 2>&1; then
    echo apt
  elif command -v dnf >/dev/null 2>&1; then
    echo dnf
  else
    echo unknown
  fi
}

install_system_deps() {
  local pm
  pm="$(detect_pm)"

  case "$pm" in
    pacman)
      echo "[ocr] package manager: pacman"
      echo "[ocr] requires sudo: pacman -S --needed tesseract tesseract-data-eng ghostscript poppler qpdf pngquant unpaper"
      sudo pacman -S --needed --noconfirm tesseract tesseract-data-eng ghostscript poppler qpdf pngquant unpaper
      ;;
    apt)
      echo "[ocr] package manager: apt"
      echo "[ocr] requires sudo: apt-get install tesseract-ocr tesseract-ocr-eng ghostscript poppler-utils qpdf pngquant unpaper"
      sudo apt-get update
      sudo apt-get install -y tesseract-ocr tesseract-ocr-eng ghostscript poppler-utils qpdf pngquant unpaper python3-venv
      ;;
    dnf)
      echo "[ocr] package manager: dnf"
      echo "[ocr] requires sudo: dnf install tesseract tesseract-langpack-eng ghostscript poppler-utils qpdf pngquant unpaper"
      sudo dnf install -y tesseract tesseract-langpack-eng ghostscript poppler-utils qpdf pngquant unpaper python3
      ;;
    *)
      echo "[ocr] unsupported package manager. Install manually: ocrmypdf tesseract(eng) ghostscript poppler"
      return 1
      ;;
  esac
}

setup_paddle_venv() {
  echo "[ocr] setting up PaddleOCR venv at $VENV_PATH"
  mkdir -p "$(dirname "$VENV_PATH")"
  python -m venv "$VENV_PATH"
  "$VENV_PATH/bin/python" -m pip install --upgrade pip setuptools wheel
  "$VENV_PATH/bin/python" -m pip install --upgrade paddlepaddle==3.1.1 paddleocr opencv-python pillow
}

setup_ocrmypdf() {
  echo "[ocr] setting up OCRmyPDF venv at $OCRMYPDF_VENV_PATH"
  mkdir -p "$(dirname "$OCRMYPDF_VENV_PATH")" "$HOME/.local/bin"
  python -m venv "$OCRMYPDF_VENV_PATH"
  "$OCRMYPDF_VENV_PATH/bin/python" -m pip install --upgrade pip setuptools wheel
  "$OCRMYPDF_VENV_PATH/bin/python" -m pip install --upgrade ocrmypdf
  ln -sf "$OCRMYPDF_VENV_PATH/bin/ocrmypdf" "$HOME/.local/bin/ocrmypdf"
}

verify() {
  echo "[ocr] verification"
  ocrmypdf --version
  tesseract --version | head -n 1
  "$VENV_PATH/bin/python" -c "import paddleocr; print('ok')"
  echo "[ocr] installed tesseract languages:"
  tesseract --list-langs
}

main() {
  install_system_deps
  setup_ocrmypdf
  setup_paddle_venv
  verify
}

main "$@"
