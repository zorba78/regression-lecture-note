---
name: tooling-paths-windows
description: 이 PC에서 Quarto/Rscript/PDF/스크린샷 실행 경로와 호출 시 주의점
type: reference
date: 2026-08-13
---

- **Quarto** 1.9.36 (RStudio 번들): PATH에 없음. `quarto.cmd` 를 공백 포함 경로로 부르면 deno 모듈 오류가 난다. 회피법 두 가지가 모두 확인됨 — (a) 8.3 단축 경로 `C:\PROGRA~1\RStudio\resources\app\bin\quarto\bin\quarto.cmd`, (b) **`.cmd` 대신 `.exe` 를 직접 호출**. Bash에서 `"/c/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe" render <파일>.qmd` 로 2026-08-24 정상 렌더(exit 0). 공백이 있어도 `.exe` 는 문제없다.
- **R**: `C:\Program Files\R\R-4.6.0\bin\Rscript.exe` (4.5.2/4.5.3/4.6.0 설치). quarto·Rscript 모두 PATH에 없음. locale은 Korean_Korea.utf8.
- **CRAN 접근 불가**: `install.packages()` 실패(네트워크 차단). 새 패키지 설치 불가하므로 base R로 해결할 것. `icons`, `HistData`, `car`, `leaps` 등 미설치.
- **PDF 텍스트 추출**: `pdftotext` (TeX Live 동봉) `C:\texlive\2025\bin\windows\pdftotext.exe`. Read 도구가 "password-protected"로 거부하는 PDF도 `pdftotext -enc UTF-8 -layout` 로는 정상 추출됨. 관련: [[reference-pdfs-locked]]
- **스크린샷**: `C:\Program Files\Google\Chrome\Application\chrome.exe --headless=new --no-sandbox --disable-gpu --hide-scrollbars --window-size=1280,1024 --virtual-time-budget=15000 --screenshot="out.png" "file:///경로#/N"` (revealjs는 `#/N`으로 N+1번째 슬라이드). 렌더 확인에 유용.
- **PowerShell 주의**: 네이티브 exe에 `2>&1` / `2>$null` 쓰지 말 것 — 종료 코드가 가짜로 1/255가 됨.
- **Quarto 렌더 후 cleanup 오류**: `embed-resources` 렌더 시 마지막에 `ERROR: ... remove '<파일>_files\libs' (os error 32)` 가 나며 종료 코드 1이 되지만, **HTML은 정상 생성 완료된 상태**다(IDE가 폴더를 잠금). 종료 코드 대신 HTML 내용으로 검증할 것.
