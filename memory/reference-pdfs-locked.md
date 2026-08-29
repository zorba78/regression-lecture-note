---
name: reference-pdfs-locked
description: references의 PDF는 Read 도구로는 거부되지만 pdftotext로는 추출 가능
type: reference
date: 2026-08-13
---

`references/` 아래 CNU·DSSI 강의노트 PDF는 Read 도구가 "PDF is password-protected"로 거부하지만, **실제로는 암호화되어 있지 않다**(raw 스캔에 `/Encrypt` 없음). `pdftotext -enc UTF-8 -layout <pdf> <out.txt>` 로 전문이 정상 추출된다(2026-08-13 확인, CNU 9개 장 + DSSI 4개 파일 모두 성공).

**Why:** 2026-08-12에는 이 PDF들을 "읽을 수 없음"으로 판단해 초안을 장 제목 뼈대만으로 작성했는데, 이는 틀린 판단이었다. 원문 대조가 가능하다.

**How to apply:** 참고자료 내용이 필요하면 Read 실패를 근거로 포기하지 말고 pdftotext를 쓸 것. HWP는 여전히 읽기 불가. 관련: [[tooling-paths-windows]]

**한계(2026-08-29 확인):** 추출되는 것은 **본문 산문과 절 제목뿐**이다. 수식·표의 수식 열은 전부 공백으로 빠진다(5장의 분산안정화 변환표는 오른쪽 설명 열만 남고 변환식 열이 통째로 소실). 그러므로 **원문의 수식을 그대로 옮겨 적었다고 주장하면 안 된다.** 5장 보강 때는 소실된 표를 델타법(∫dμ/√g(μ))과 대수 전개로 **다시 유도해서** 채웠고, 슬라이드에 유도 과정을 함께 실었다. 다음에 같은 표를 볼 때 "원문과 다르다"고 고치지 말 것.
