---
name: lecture-slides
description: 회귀분석 특강용 Quarto(revealjs) 강의 슬라이드 생성·수정. 슬라이드, 발표자료, 강의자료, presentation, qmd 작성 요청 시 사용.
argument-hint: <주제 또는 장(chapter)>
---

# 강의 슬라이드 생성 (Quarto revealjs)

청중: 원자력 안전기술원 박사급 연구원 (통계 비전문가).
목표: 회귀분석 전반 이론(가중회귀 포함)을 초등학생도 이해할 수 있는 눈높이로 전달.

## 커리큘럼 뼈대 (references 기반)

`references/cnu-regression-lecture-note/강의노트/`의 장 구성을 기본 골격으로 사용:

1. 서론 (회귀분석이란) → 2. 기초 행렬 이론 → 3. 단순선형회귀 → 4. 다중선형회귀
→ 5. 회귀진단 및 보정 → 6. 모형 비교와 변수선택 → 7. 사례분석(아이스크림 데이터)
→ 8. **일반화 가중회귀모형** (특강 목적에 명시된 핵심 주제) → 9. 가변수회귀모형

보조 자료: `references/DSSI-regression-lecture-note/` (소개·단순선형·중회귀·변수선택 PDF).
PDF는 Read 도구로 읽을 수 있고 HWP는 읽을 수 없다.

## 슬라이드 작성 원칙

- **한 슬라이드 한 아이디어.** 글머리표 최대 4~5개.
- 새 개념 도입 순서: **비유/직관 → 그림 → 수식 → R 예제 → 한 줄 요약** (easy-explain 스킬의 구조를 따름).
- 수식은 반드시 기호 설명을 동반한다. 유도 과정이 길면 본 슬라이드에는 결과만, 유도는 부록(appendix) 슬라이드로 분리.
- 본문은 한국어, 그림·표의 제목·캡션·footnote는 영어 (CLAUDE.md 행동 규칙 5).
- 그림·예제 데이터가 필요하면 r-example 스킬 규칙에 따라 R 스크립트를 만들어 생성한다.

## 파일 규칙

- 초안 `.qmd`: `quarto/agent/<YYYY-MM-DD>/` (작업 시점 날짜 폴더, 예: `quarto/agent/2026-08-11/`)
- 슬라이드에 삽입할 그림: `output/agent/<YYYY-MM-DD>/`
- 최종 확정본(렌더된 발표 파일): `presentation/`
- YAML 최소 예시:

```yaml
---
title: "회귀분석의 이해"
subtitle: "원자력 안전기술원 특강"
format:
  revealjs:
    slide-number: true
    transition: fade
lang: ko
---
```

## 검증 (필수)

1. 작성 후 `quarto render <파일>.qmd` 실행 → 에러 없이 HTML 생성 확인.
2. 수식($...$, $$...$$)이 포함된 슬라이드는 렌더 결과에서 LaTeX 문법 오류가 없는지 확인.
3. 렌더 실패 시 원인을 수정하고 재렌더가 통과할 때까지 반복.
