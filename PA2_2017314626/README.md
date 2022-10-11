# NONOGRAM App
네이버 검색 또는 갤러리에서 이미지를 가져와 흑백화한 후 NONOGRAM 게임으로 만들어주는 프로그램입니다.

## 기능 설명
### 검색 기능
+ 네이버 검색 api를 이용하여 네이버에서 키워드를 검색합니다. 그 후 가장 상단의 이미지를 노노그램 게임으로 생성합니다.
<img width="998" alt="image" src="https://user-images.githubusercontent.com/86291473/195107118-142faf47-78c1-4daf-bc3c-b4e032adb1e2.png">
  
### 갤러리 기능
+ 자신의 갤러리에서 이미지를 선택합니다. 그 후 노노그램 게임으로 생성합니다.
<img width="991" alt="image" src="https://user-images.githubusercontent.com/86291473/195107259-f330b91c-6baa-483d-8898-285ac0b613d4.png">

### 노노그램 게임화 과정
1. 이미지를 정사각형화 합니다.
2. 이미지를 흑/백으로 변환합니다.
3. 이미지를 20x20 개의 조각으로 자릅니다. 이후 흑 또는 백으로 모든 칸을 결정합니다. (grayscale value > 128일 때 백, 그 외를 흑으로 결정합니다.)
4. 좌측과 상단에 게임을 위한 수치를 표시합니다.
<img width="1015" alt="image" src="https://user-images.githubusercontent.com/86291473/195108416-b869377e-c7cb-457b-bc98-f8f69a9ab3ae.png">
