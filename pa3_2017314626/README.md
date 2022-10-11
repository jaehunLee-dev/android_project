# Corona Live App

국내 및 세계의 코로나 / 백신 현황을 보여주는 어플리케이션입니다. (https://corona-live.com/ 의 몇몇 기능들을 구현한 app입니다.)

## 페이지 구성
### Login 페이지
+ 메인 페이지에서 로그인이 가능합니다. (별도의 백엔드는 구현되어있지 않으며 기본 설정으로 id: skku / pw: 1234 로 설정되어 있습니다.)
+ 로그인에 성공할 시 성공 메세지가 표시되며 Start Corona Live 버튼을 누르면 메인 페이지로 넘어갑니다.)
<img width="1026" alt="image" src="https://user-images.githubusercontent.com/86291473/195096477-07f4cf59-cd70-4103-ac84-bd0bf904db43.png">
  
### Navigation 페이지
+ Cases/Death 페이지 또는 백신 페이지로 이동할 수 있는 페이지입니다. Case / Death 페이지는 코로나 총 사례 및 사망자 통계를, 백신 페이지는 백신 통계를 보여줍니다.
![image](https://user-images.githubusercontent.com/86291473/195098500-96b3f92a-3fc8-489d-a4fa-41faaabe5fe6.png)

### Vaccine 페이지
+ 외부 api를 HTTP request를 통해 활용하여 구현하였습니다. (https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json)
+ 상단의 표는 전세계의 백신 현황(Total vacc), 한국 정보가 업데이트된 날짜(Parsed latest date), 전세계의 백신 완전접종자수(Total fully Vacc),당일 백신 접종자수(Daily Vacc)을 보여줍니다.
+ 중간의 그래프는 다음의 정보를 보여줍니다.
  - Graph 1: 최근 7일간의 Total Vacc
  - Graph 2: 최근 7일간의 Daily Vacc
  - Graph 3: 최근 28일간의 Daily Vacc
  - Graph 4: 최근 28일간의 Daily Vacc
<img width="318" alt="image" src="https://user-images.githubusercontent.com/86291473/195099038-7d5c712d-f5f3-41c3-bbe4-9a24ee6699e8.png">
