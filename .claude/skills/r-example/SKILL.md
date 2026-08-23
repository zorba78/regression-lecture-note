---
name: r-example
description: 강의용 R 예제 스크립트·그림·시뮬레이션 데이터 생성. R 코드, 예제, 그림 생성, 시뮬레이션, plot 요청 시 사용.
argument-hint: <예제 주제>
---

# 강의용 R 예제 생성

## 코드 규칙

- 스크립트 최상단 주석 헤더 (영어, CLAUDE.md 행동 규칙 3):

```r
# Date        : YYYY-MM-DD
# Description : <one-line summary of what this script does>
# File        : <filename>.R
```

- 모든 주석은 영어로 상세하게 작성 (CLAUDE.md 행동 규칙 2).
- 난수를 쓰는 코드는 반드시 `set.seed()`로 재현성 확보.
- 패키지는 최소한만 사용. base R로 충분하면 base R 사용 (Simplicity First).
- 그림의 제목·축 라벨·범례·캡션은 영어.

## 저장 규칙 (작업 시점 날짜 폴더, 예: 2026-08-11)

| 산출물 | 위치 |
|---|---|
| R 스크립트 | `code/agent/<YYYY-MM-DD>/` |
| 그림·표 등 결과물 | `output/agent/<YYYY-MM-DD>/` |
| 생성한 데이터 | `data/derived-data/agent/<YYYY-MM-DD>/` |

- 그림은 스크립트 안에서 `png()`/`ggsave()` 등으로 위 경로에 저장하도록 작성한다 (수동 캡처 금지).

## 기존 예제 재활용

- `references/cnu-regression-lecture-note/강의노트/R 예제/` 아래 장별 R 코드와 데이터(예: 7장 `ice.csv.csv` 아이스크림 데이터)를 우선 검토하고, 강의 흐름에 맞으면 재활용·개선한다.
- 재활용 시 출처(어느 장의 예제인지)를 스크립트 헤더에 명시한다.

## 검증 (필수)

1. 작성한 스크립트를 `Rscript <파일>.R`로 실행해 에러 없이 완료되는지 확인.
2. 그림 파일이 지정 경로에 실제로 생성되었는지 확인.
3. 결과에 수치가 포함되면 계산 과정을 주석 또는 출력으로 남긴다 (검산 규칙).
