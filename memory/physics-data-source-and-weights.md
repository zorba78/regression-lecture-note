---
name: physics-data-source-and-weights
description: 06장 물리 측정 예제의 원 출처, CNU 코드의 오기 1건, 가중치는 1/SD^2 라는 사용자 승인 결정
type: project
date: 2026-11-26
---

06장 물리 측정 예제는 `alr4::physics` (Weisberg, S. 2014, *Applied Linear Regression* 4판 부속 자료; 원자료 Weisberg, H. et al. 1978, *Physical Review D* 17, 2875–2887; 끝 쪽 2887은 alr4 패키지 문서에만 있고 APS 페이지에서는 미확인) 이다. 2026-11-26 CRAN `alr4` 1.0.7 소스의 `data/physics.rda`, `man/physics.Rd` 를 내려받아 대조했다.

- CNU 강의노트 R 코드(`references/cnu-regression-lecture-note/강의노트/R 예제/제8장 예제 R코드.R`)의 4번째 x 값 0.255 는 원본 0.225 의 오기다. 2026-11-25 이전 덱·그림·`export-data.R` 이 이 값을 물려받았다.
- 셋째 열은 분산이 아니라 표준편차(SD: 17, 9, 9, 7, 7, 6, 6, 6, 5, 5)다. 가중치는 `1/SD^2`. CNU 코드와 이전 덱은 `1/w` 를 썼다.
- 사용자 결정(2026-11-26): 원본대로(x4 = 0.225, 가중치 1/SD^2) 고친다. 06장을 WLS 검교정 중심으로 보강한다(가중 잔차 → 적합결여 카이제곱 → 2차식 → 추가제곱합 F → 절차 정리, 역추정 추가, GLS는 3장 정도로 축소, 감쇠 곡선 4장 유지). 청중이 특강을 요청한 이유가 WLS 검교정 문제다.
- 원본 기준 검산값(오케스트레이터 R 계산): 1차 WLS 148.47(SE 8.08), 530.84(SE 47.55), R² 0.940, 가중 RSS 21.95(df 8); 2차 183.83(6.46), 0.97(85.37), 1597.50(250.59), R² 0.991, 가중 RSS 3.23(df 7); 2차항 F = 40.64, p = 0.00038.
- Weisberg 교재의 장·절 번호는 교재를 열지 못해 확인하지 못했다.

- 반영 결과(2026-11-26): 06장 H2 30(이전 25). 물리 예제 11장(자료 → 1차식 2장 → 가중 잔차 → 잔차 분석 → 적합결여 검정 → 2차식 → 비교 → 절차 → 역추정 2장), GLS 3장(`유도`·`WLS와의 관계`·`풀이 절차` 삭제·통합). 새 그림 `output/agent/2026-11-26/fig-p06-*.png`, 검산 `code/agent/2026-11-26/check-ch06-physics-wls.R`. 배포용 `docs/data/physical-measurement.csv` 도 수정(열 이름 w → SD). 역추정은 자체 유도(교재 장·절 미확인), "환산 카이제곱" 용어는 출처 미확보로 넣지 않음.

**Why:** 덱의 규칙("가중치는 분산의 역수")과 예제 계산이 어긋나 있었고, 자료값 오기는 원본과 대조하기 전에는 드러나지 않는다.

**How to apply:** 참고자료의 R 코드에서 자료를 옮길 때는 원 패키지·문헌과 값을 대조한다. 관련: [[reference-pdfs-locked]], [[gls-example-lakehuron]], [[nuclear-regression-cases]]
