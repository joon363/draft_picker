from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict, Optional
import json
import pandas as pd # 엑셀 파일 로드를 위해 추가
import numpy as np
import asyncio
import os 

app = FastAPI()

# CORS 설정 추가: 개발 환경에서는 모든 출처를 허용합니다.
origins = [
    "*",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 더미 데이터 (Fallback용) ---
DUMMY_CANDIDATES = [
   {
      "name":"최인우",
      "applied1":"4. 대외협력국",
      "applied2":"7. 비서실",
      "applied3":null,
      "comment":"총학생회장단 (직책)버디로써; 야망이 많지만, 좋은 팀원감 그 이상 그 이하도 아니다. 나중에 국장으로 가져가거나 하기는 어렵다. 고지식하다…\n대협에서 받으면 ok, 아니면 사총/재정으로.\n중집위장\n충전을 제때 하도록 하겠습니다.\n미전실의 (든든한국밥) 포지션\n\n1지망 국장 (대협국)\n\n2지망 국장 (비서실)\n근데 비서실 일을 주면 잘할거 같은데 성격상 미전실이 좀 더 잘 어울리는 거 같아요\n미전 사총 넣는거 고려, 대협이랑 비서는 아니다.",
      "transcript_url":"https://docs.google.com/document/d/14SKCOzkfGH8xo9zXZxn0HCj4RgN5TKzeJaejibp-xow/edit?tab=t.0",
      "assigned":{
         "8. 미래전략실":"confirmed"
      }
   },
   {
      "name":"이성현",
      "applied1":"7. 비서실",
      "applied2":"1. 사무총괄국",
      "applied3":"8. 미래전략실",
      "comment":"총학생회장단 (중집위장)\n책임감 워딩이 좋았다.\n잘 못 녹아들것 같은 느낌.\n단체 장이랑 conflict가 날 것 같다.\n1지망 국장 (비서실)\n국원을 하면 안된다. 마인드만 잘 장착돼있으면 ㄱㅊ을 것이다.\n2지망 국장 (사총국)\n조큼 아쉽다. 뚜렷한 정체성이 없다 (리더를 뽑는 자리가 아닌데…) \n엘리트였으면 떨궜다. 다른 친구들 더 보고 싶다.",
      "transcript_url":"https://docs.google.com/document/d/1g-1j_2HHF4yCWWQc0__7Ia6qM_5794x8GMaU6KeXql8/edit?tab=t.0",
      "assigned":{
         "7. 비서실":"confirmed"
      }
   },
   {
      "name":"김태린",
      "applied1":"4. 대외협력국",
      "applied2":"8. 미래전략실",
      "applied3":"6. 문화기획국",
      "comment":"총학생회장단 (직책)\n\n1지망 국장 (대협국)\n대협국 깔이긴 한데,,, 영서랑 성향이 반대… 칼같다 (무섭다)\n영서선배 하고 싶은 말 있으면 적어주세용\n\n2지망 국장 (미전국)",
      "transcript_url":"https://docs.google.com/document/d/1thI_wJkGRLlywqzEsp3k5KjodscISslXDNJP9Gel9NE/edit?tab=t.0",
      "assigned":{
         "4. 대외협력국":"confirmed"
      }
   },
   {
      "name":"조은강",
      "applied1":"7. 비서실",
      "applied2":"5. 나눔복지국",
      "applied3":"2. 재정관리국",
      "comment":"총학생회장단 (중집위장)\n쌈뽕해보이는데 비서실 지원하면서 공약을 안봤더라 . . \n어떤국이어울리려나\n\n1지망 국장 (비서국)\n비서 안데려갈게요 \n2지망 국장 (나눔국)\n그냥 어느 국에 들어가도 일을 잘하고 순둥하게 스며들 것 같다. 그래서 나눔들어오셔도 좋아용 보류 해야겟다 보류ㅜ(개인적을)",
      "transcript_url":"https://docs.google.com/document/d/1DkLdKH79G_4tyNcJvdm4_YI-DmrqmWhOOnqwmuvcoVo/edit?tab=t.0",
      "assigned":{
         "7. 비서실":"confirmed"
      }
   },
   {
      "name":"왕준섭",
      "applied1":"4. 대외협력국",
      "applied2":"8. 미래전략실",
      "applied3":null,
      "comment":"총학생회장단 (중집위장)\n사총 재정 낫배드. @김성겸 영상 봐보세여.\n총학생회장\n얘 뒷풀이 잘 안옴!!\n표정도 원래 웃상이다\n위계질서는 확실하다.\n\n1지망 국장 (대협국, 비서실장)\n욱하는 성격이 있을 것 같다. 소통이 중요한 대협국에서는 트러블이 있을 수 있을 것 같다.\n\n2지망 국장 (미전실)\n미전실에 맞는 메리트는 없다. ",
      "transcript_url":"https://docs.google.com/document/d/1-fBSDkxWeMhtEDjo77VQb-q9yvZ5-3aEVQ_73z0tAxg/edit?tab=t.0",
      "assigned":{
         "8. 미래전략실":"confirmed"
      }
   },
   {
      "name":"강창민",
      "applied1":"3. 소통연결국",
      "applied2":"2. 재정관리국",
      "applied3":"8. 미래전략실",
      "comment":"지망 국장 (소통국)\n음… 알리미 대답만 있나…\n나도 애매함…\n비서실장인데, 이거 에반데 왤캐 준비 안해갔냐\n알리미 간수 하시죠ㅋㅎㅋㅎㅋㅎ\n\n2지망 국장 (재정국)\n음 저랑은 잘 맞는지 모르겠음\n별로 준비를 했는진 잘…\n흠… 다시 봐바야겠다…",
      "transcript_url":"https://docs.google.com/document/d/1XzICHD9C3-AFKg-nMWqORYBhCK7j4A6IcKX6LUVwMlo/edit?tab=t.0",
      "assigned":{
         "보류":"confirmed"
      }
   },
   {
      "name":"유태권",
      "applied1":"3. 소통연결국",
      "applied2":"5. 나눔복지국",
      "applied3":"7. 비서실",
      "comment":"총학생회장단 (중집위장)\n태도는 마음에 든다. 그냥 귀여운 1학년. 다양한 의견을 듣는걸 좋아한다는 점, 더 다양한 채널로 알려야 한다는 것이 plus. 구체적으로 생각해놓은게 없는게 살짝 아쉽긴 함.\n비서실 감성이긴 함 (boarding pass)\n\n1지망 국장 (소통국)\n보라.. 개선.. 돈줘요 회장단 나도 하고 싶어\n소통국 일은 어차피 배우면 된다. 애들 조합 보고 뽑고 싶다.\n\n2지망 국장 (나눔국)\n나눔국 와서 학교를 바꾸지는 못하기 때문에 실망할 것 같음.",
      "transcript_url":"https://docs.google.com/document/d/1luSU3ssOBvCkPfq4qDlvL7gOpZ1I8ekuT8cyeAk1fkg/edit?tab=t.0",
      "assigned":{
         "1. 사무총괄국":"confirmed"
      }
   },
   {
      "name":"전혁준",
      "applied1":"6. 문화기획국",
      "applied2":"5. 나눔복지국",
      "applied3":"4. 대외협력국",
      "comment":"총학생회장단 (중집위장)\n네즈코 개호감\n부스 쓸데없는거 줄이고 싶다는게 맘에 들음.\nㄹㅇ미친놈인거 맞는듯\n밥먹을사람 구하고 싶어요 . . → 호감.\n\n1지망 국장 (문기국)\n데려갈게요 \n\n2지망 국장 (나눔국)\n귀엽다. ㄹㅇㄹㅇㅇㄹㅇㄹㅇㄹㅇㄹㅇㄹㅇㄹ\n익명의 레퍼런스\n특급 인싸로 유명하다 + 친화력 좋다\n\n소통국장\n미친놈임. 귀엽다.",
      "transcript_url":"https://docs.google.com/document/d/1c8BwQxXsZOu9JMGn6CEo0NzOKWmkFmQnVjoJRUp2Qbw/edit?tab=t.0",
      "assigned":{
         "6. 문화기획국":"confirmed"
      }
   },
   {
      "name":"유영주",
      "applied1":"4. 대외협력국",
      "applied2":"8. 미래전략실",
      "applied3":"7. 비서실",
      "comment":"총학생회장단 (중집위원장)\n미전 감성",
      "transcript_url":"https://docs.google.com/document/d/19zUGgKe94u0QssFRzfwdeQINtvIc2y9O8UuHLw7Dg-c/edit?tab=t.0",
      "assigned":{
         "8. 미래전략실":"confirmed"
      }
   },
   {
      "name":"김승현",
      "applied1":"1. 사무총괄국",
      "applied2":"5. 나눔복지국",
      "applied3":"2. 재정관리국",
      "comment":"총학생회장단 (중집위장)\n사총감. \n\n1지망 국장 (사총국)\n굿굿\n\n2지망 국장 (나눔국)\n나눔 와도 되는데 자신의 능력이 사총, 재정에 더 잘 맞아 보인다. ",
      "transcript_url":"https://docs.google.com/document/d/1oIoH9Cp3qCeixQZ-ZeYUCMaz1COaNIgS0si2AoA07KY/edit?tab=t.0",
      "assigned":{
         "1. 사무총괄국":"confirmed"
      }
   },
   {
      "name":"이경록",
      "applied1":"6. 문화기획국",
      "applied2":"7. 비서실",
      "applied3":"4. 대외협력국",
      "comment":"총학생회장단 (중집위장)\n준비 미흡. 문기국 행사를 참여 안해봤는데 문기를 쓴다라…\n문기국감은 아닌듯\n학회장 잘 하려나…\n\n1지망 국장 (문기국)\n느낌은 뭐 괜찮은데 솔직히 면접내용은 하점임\n솔직히 재밌긴하고 같이 일해볼만은 함\n근데 어떻게 갈고 닦을지 고민임\n다른 국 보내지 말고 문기로 데려오는게 나을 것 같다.\n근데 어디까지 통제할 수 있을지 모르겠어서 고민 좀 해보긴 해야할 것 같음\n\n2지망 국장 (비서실)\n공약을 알고 있는게 없다.\n에바.",
      "transcript_url":"https://docs.google.com/document/d/1GZP1mQuuKpsRHsW5mrBxavVCHQJ12whH4SkAY_4MxEU/edit?tab=t.0",
      "assigned":{
         "보류":"confirmed",
         "6. 문화기획국":"candidate"
      }
   },
   {
      "name":"나도연",
      "applied1":"6. 문화기획국",
      "applied2":"5. 나눔복지국",
      "applied3":"2. 재정관리국",
      "comment":"1지망 국장 (문기국)\n싹싹한데 근데 뭐 면접은 평범함 좀 친해져 보고 싶긴한데 그냥 딱 평균치임\n\n2지망 국장 (나눔국)\n귀엽다 ㅎㅎ 잘 웃고. 싹싹하게 참여 잘할 것 같다.",
      "transcript_url":"https://docs.google.com/document/d/1XRcxunDStqKRtUzYQ1KxpN6W-Was9ikiyvtHLGeoaCA/edit?tab=t.0",
      "assigned":{
         "5. 나눔복지국":"confirmed"
      }
   },
   {
      "name":"최진현",
      "applied1":"1. 사무총괄국",
      "applied2":"8. 미래전략실",
      "applied3":null,
      "comment":"1지망 국장 (사총국)\n잘하는데, 데려가고 싶지는 않다.\n일은 레전드로 잘할듯.\n\n2지망 국장 (미전실)\n아카이빙 시키면 진짜 잘할 것 같다. ",
      "transcript_url":"https://docs.google.com/document/d/1iQzjOZUlwwT_OodTVSxeBO_H28DhSCa6R5Ou29TWTn8/edit?tab=t.0",
      "assigned":{
         "8. 미래전략실":"confirmed"
      }
   },
   {
      "name":"송준영",
      "applied1":"3. 소통연결국",
      "applied2":"2. 재정관리국",
      "applied3":null,
      "comment":"총학생회장단 (중집위원장)\n1지망 국장 (소통국)\n이것저것 잘 찾아옴ㅎㅎ\n\n2지망 국장 (재정국)\n준비를 좀 해온 느낌\n어디가나 열심히 할 느낌",
      "transcript_url":"https://docs.google.com/document/d/1XU3rH3wnDO5QG7Ab_Nbr7fSwPhe4UpVOKfPrnejxd6g/edit?tab=t.0",
      "assigned":{
         "3. 소통연결국":"confirmed"
      }
   },
   {
      "name":"제승규",
      "applied1":"8. 미래전략실",
      "applied2":"4. 대외협력국",
      "applied3":"6. 문화기획국",
      "comment":"없음",
      "transcript_url":"https://docs.google.com/document/d/1wJuUR2O2LR-UqQbGc7tpRYzj9ctLc4sVJtNeoseJmAc/edit?tab=t.0",
      "assigned":{
         "8. 미래전략실":"confirmed"
      }
   },
   {
      "name":"이수연",
      "applied1":"6. 문화기획국",
      "applied2":"5. 나눔복지국",
      "applied3":null,
      "comment":"\n1지망 국장 (문기국)\n좋음 굳굳\n\n2지망 국장 (나눔국)\n밥도 잘먹고 사장님도 잘대하고 나눔 ㄱㄱ",
      "transcript_url":"https://docs.google.com/document/d/1Rcw74nlUwPA4pyesHf0myI9MPrvlfKr3SmDLuXi_DP8/edit?tab=t.0",
      "assigned":{
         "6. 문화기획국":"confirmed"
      }
   },
   {
      "name":"권지언",
      "applied1":"2. 재정관리국",
      "applied2":"5. 나눔복지국",
      "applied3":"4. 대외협력국",
      "comment":"총학생회장단 (중집위장)\nGOAT. 태도도 좋고 성격도 부드러운데 칼같을때는 칼같을듯. 다만 다른 팀원들이 조금 무서워 보일수도?\n\n1지망 국장 (재정국)\n제가 데려가겠습니다 ㅎㅎ\n\n2지망 국장 (나눔국)\n재정 보내줘야될 재정의 인재이다! 웃으면 귀엽더라고요 말도 잘해요 선배랑(저랑)",
      "transcript_url":"https://docs.google.com/document/d/1VRy0gh7cU66SHqwiD-Wwwt8dhpq_6ILs2v2zIFtirVo/edit?tab=t.0",
      "assigned":{
         "2. 재정관리국":"confirmed"
      }
   },
   {
      "name":"최건하",
      "applied1":"3. 소통연결국",
      "applied2":"2. 재정관리국",
      "applied3":null,
      "comment":"총학생회장단 (중집위장)\n첫인상 개씹호감. \n진짜 준비 열심히한듯\n\n1지망 국장 (소통국)\n보라 열심히 본거 진짜 감사합니다ㅠㅠㅠㅠㅠㅠ 물론 소통 관리국이 되었지만\n준비 열심히 해온게 보이고 말 잘해요\n\n익명의 보우시즈 레퍼런스\n말을 예쁘게 하는 착한 에겐남\n\n2지망 국장 (재정국)\n소통국으로 이륙",
      "transcript_url":"https://docs.google.com/document/d/14lC_YH2cx89_cvoCkBi4C145CXHloPfLxxNGIJLU9UI/edit?tab=t.0",
      "assigned":{
         "3. 소통연결국":"confirmed"
      }
   },
   {
      "name":"김혜인",
      "applied1":"6. 문화기획국",
      "applied2":"3. 소통연결국",
      "applied3":"2. 재정관리국",
      "comment":"총학생회장단 (중집위장)\n실행까지 밀어붙인 점이 괜찮다. 걍 긴장한건지 모르겠는데 조용조용한 느낌인가…? 치어로 친구한테 한번 물어보면 좋을듯.\n\n1지망 국장 (문기국)\n괜찮은 것 같은데\n치어로면 뭐 친화력 좋지 않을까\n익명의 레퍼런스\n지원자중 김동규와 전 연인이라고 함\n\n2지망 국장 (소통국)\n한거 많고요.. 할말 다 하는거 같아요.. \n경력 많은듯 소통 이것저것 하는 것도 많이 해본거 같",
      "transcript_url":"https://docs.google.com/document/d/1732lkgLCWlaIL2xZ1jGoXaBySder8MZSwshRpSdcvIQ/edit?tab=t.0",
      "assigned":{
         "6. 문화기획국":"confirmed"
      }
   },
   {
      "name":"김세현",
      "applied1":"5. 나눔복지국",
      "applied2":"3. 소통연결국",
      "applied3":"4. 대외협력국",
      "comment":"총학생회장\n차라리 문기.\n나눔국은 안될듯\n총학생회장단 (중집위장)\n엄청난 나르시시스트\n별로 하고 싶지 않아 보임, 일은 잘할 것 같음.\n그래서 오히려 자존심 안 내세우고 한학기만 일 반짝 하고 가는 느낌으로 할듯?\n1지망 국장 (나눔국)\n공식적인 면접 자리인데도 단어나 어투가 조금\n신입들이 기 눌릴듯\n비서실장\n 나눔국에 현민씨와 사귀고 있다고 함\n익명의 반도체공학과 학우\n제발 거르세요 \n얘 부원으로 뽑으면 그쪽 부장은 자살방지 위원회에 데랴가야 함\n반도체 학생회때 얘 땜에 엄청 고생많이했음\n2지망 국장 (소통국)\n뭔가 자세하고 의견 좋은거 많이 말씀해주셨는데.. 무서울수도..ㅎㅎㅎ",
      "transcript_url":"https://docs.google.com/document/d/1xVauFbD_wD6xjs1weE5u3G-jZf1kC_rQ7Cv4KpbVOLA/edit?tab=t.0",
      "assigned":{
         "보류":"confirmed"
      }
   },
   {
      "name":"홍준우",
      "applied1":"3. 소통연결국",
      "applied2":"4. 대외협력국",
      "applied3":"6. 문화기획국",
      "comment":"총학생회장단 (중집위장)\n소통도 대협도 문기도 ㄱㅊ을듯 함.\n\n1지망 국장 (소통국)\n애는 괜찮음\n어딜 가도 잘할것 같다.\n\n3지망 국장 (문기국)\n에잉 쯧 싹싹하고 마음에 드는데 문기 너무 관심 없어 보임\n아무데나 데려가도 어떻게든 잘 쓸듯",
      "transcript_url":"https://docs.google.com/document/d/1QY4d8y8InHOnlrYTHqI6tsoftxOl6V16dAeTXhg599s/edit?tab=t.0",
      "assigned":{
         "4. 대외협력국":"confirmed"
      }
   },
   {
      "name":"임준서",
      "applied1":"6. 문화기획국",
      "applied2":"5. 나눔복지국",
      "applied3":"4. 대외협력국",
      "comment":"총학생회장단 (중집위장)\n굉장히 생각이 깊어 보이고, 할거 있으면 잘 할것같음.\n\n1지망 국장 (문기국)\n데려갈게요 \n너 내 애착 인형 후보다\n\n익명의 축준위 1\n일 잘한다. 당일날 시키는거 잘 했다.\n \n익명의 축준위 2\n당일날 뭔 일을 냈다..\n\n2지망 국장 (나눔국)\n좋은 친구 매우. 귀엽. ",
      "transcript_url":"https://docs.google.com/document/d/1AhKZ4jotSd1kookguzBj-jdWNVdQWDSJ931T9huWgqY/edit?tab=t.0",
      "assigned":{
         "6. 문화기획국":"confirmed"
      }
   },
   {
      "name":"강동희",
      "applied1":"7. 비서실",
      "applied2":"6. 문화기획국",
      "applied3":"3. 소통연결국",
      "comment":"1지망 국장 (비서실)\n대리고 갈 예정 ㅋㅋ(아오^_^) \n\n2,3지망 국장 (소통(문기 대타)국)\n일단 말 잘함. 공약 다 앎, 열정적일거 같을듯? ",
      "transcript_url":"https://docs.google.com/document/d/1c225_WTqCr6W13FMMdZsTcEajSvuxoKgxTdbj7AxX1M/edit?tab=t.0",
      "assigned":{
         "7. 비서실":"confirmed"
      }
   },
   {
      "name":"이현민",
      "applied1":"7. 비서실",
      "applied2":"5. 나눔복지국",
      "applied3":"3. 소통연결국",
      "comment":"2지망 국장 (나눔국)\n저는 나눔국 오캐! 나눔국 긔긔",
      "transcript_url":"https://docs.google.com/document/d/1IaB41_uswYH5kxRy-XHoXrkDMZfKtD4vGqpWPiJ0F4k/edit?tab=t.0",
      "assigned":{
         "5. 나눔복지국":"confirmed"
      }
   },
   {
      "name":"조현우",
      "applied1":"5. 나눔복지국",
      "applied2":"4. 대외협력국",
      "applied3":"3. 소통연결국",
      "comment":"총학생회장단 (총학생회장)\n좋은게 하나도 없다. (장점이 하나도 없다)\n정정) 레퍼런스 체크를 통해 괜찮다고 판단.\n\n1지망 국장 (나눔국)\n표정이 두꺼워서 어떤 사람인지 파악을 못했어요ㅠ 얘도 한 번 웃으라고 해야되나\n\n레퍼첵\n성격 좋고 일 야무지다.\n레퍼첵\n멋선\n가십거리를 좀 좋아함\t\n\n3지망 국장 (소통국)\n저도 파악이 어려워요.. 근데 열심히 안할 분은 아닐듯??",
      "transcript_url":"https://docs.google.com/document/d/1I84fXo5nSi9cZbu4w4zuS1jZMri9wkhSpuyDYAoKrf4/edit?tab=t.0",
      "assigned":{
         "5. 나눔복지국":"confirmed"
      }
   },
   {
      "name":"홍이준",
      "applied1":"7. 비서실",
      "applied2":"4. 대외협력국",
      "applied3":"3. 소통연결국",
      "comment":"3지망 국장 (소통국)\n진짜 미전 느낌인데",
      "transcript_url":"https://docs.google.com/document/d/15EG5B8iOXM2kOm02VP0E1m5xQQ_3_amhg3dq6L9h60s/edit?tab=t.0",
      "assigned":{
         "7. 비서실":"confirmed"
      }
   },
   {
      "name":"김여정",
      "applied1":"5. 나눔복지국",
      "applied2":"2. 재정관리국",
      "applied3":null,
      "comment":"총학생회장단 (부회장)\n실제로 반공과 기획팀에서 어느정도 꼼꼼한지, 어떻게 일을 진행해왔는지 레퍼 체크가 필요해 보임.\n재정은 좀 힘들지 않을까 싶음. \n1지망 국장 (나눔국)\n말이 너무 추상적임. 재정을 잘한다고 하는데, 돈을 쓰는 방식을 설명하는게 전부 추상적임. \n같이 일하고 싶은 feel은 안옴니당.. \n\n2지망 국장 (재정국)\n뒷조사할게요",
      "transcript_url":"https://docs.google.com/document/d/1p3c5wRQSg2oVyu7Q2V8N7vpqzmEMDod3GEaRe25-C20/edit?tab=t.0",
      "assigned":{
         "2. 재정관리국":"confirmed"
      }
   },
   {
      "name":"유현종",
      "applied1":"6. 문화기획국",
      "applied2":"4. 대외협력국",
      "applied3":"5. 나눔복지국",
      "comment":"1지망 국장 (문기국)\n면접은 잘보는데\n흠 뭐 모르겠음\n묘하게 싸한디\n\n2지망 국장 (대협국)\n4. 3지망 국장 (나눔국)\n일은 같이해도 같이 놀러가고 싶지 않아요.",
      "transcript_url":"https://docs.google.com/document/d/1Sk2OrDPF9aShTbn9IryQexDkQ3B44yDZRQrHM2ojixc/edit?tab=t.0",
      "assigned":{
         "보류":"confirmed"
      }
   },
   {
      "name":"김예성",
      "applied1":"1. 사무총괄국",
      "applied2":"7. 비서실",
      "applied3":"6. 문화기획국",
      "comment":"총학생회장\n'진짜'가 왔다\n얘는 총학생회장 시켜도 되겠다.\n총학생회장단 (중집위장)\n이렇게 쌈뽕할줄은 몰랐네",
      "transcript_url":"https://docs.google.com/document/d/18MLETKa4rNxiBGPp2ml4edrvr-qqJrYUp863gvEQzPk/edit?tab=t.0",
      "assigned":{
         "1. 사무총괄국":"confirmed"
      }
   },
   {
      "name":"김동규",
      "applied1":"3. 소통연결국",
      "applied2":"6. 문화기획국",
      "applied3":"2. 재정관리국",
      "comment":"총학생회장단 (중집위원장장)\n준비를열심히안했군 ㅋㅋ\n얼리버드 감인진 잘 모르겠음 . . . 보류 감\n개인적으로, 웃긴 친구임\n\n1지망 국장 (소통국)\n생각보다 하는 일을 몰라요… \n어렵다!\n\n재정국장\n축준위 할때 교통통제 해야 하는데 자느라 안왔다\n지각이 좀 있었다\n\n2지망 국장 (문기국)\n뭐 근데 긴장한 것 같긴한데 생각보다 재밌을 것 같고 일머리는 있는 것 같기\n일하기 편할 것 같아. ",
      "transcript_url":"https://docs.google.com/document/d/15pCH9aGB3jPWB1MT0OKETL7hUnCV0WySLf1xnWsndqI/edit?tab=t.0",
      "assigned":{
         "보류":"confirmed"
      }
   },
   {
      "name":"이희재",
      "applied1":"6. 문화기획국",
      "applied2":"4. 대외협력국",
      "applied3":"2. 재정관리국",
      "comment":"1지망 국장 (문기국)\n자아가 세보여서 걱정이긴 한데\n면접 내용 상당히 굳굳\n웃기다는 평가+예의 잘지킨다는 평가 굉장히 호",
      "transcript_url":"https://docs.google.com/document/d/1_YXVnSNnCkT-4SHRXYP2DoG432-rijtjoIoGvByVtWg/edit?tab=t.0",
      "assigned":{
         "4. 대외협력국":"confirmed"
      }
   },
   {
      "name":"백지훈",
      "applied1":"5. 나눔복지국",
      "applied2":"6. 문화기획국",
      "applied3":null,
      "comment":"총학생회장단 (중집위장)\n알리미임을 잘 어필해서 좋았다.\n아주 약간의 자만심 \n면접 보느라 수고했다고 해주심\n\n1지망 국장 (나눔국)\n굳 뽀이시다. 방긋 뽀이.\n\n2지망 국장 (문기국)\n면접 보느라 수고 많으십니다!!!!!\n뭐 느좋\n나눔에서 데려갈듯\n굳이 싸울 생각까지는 없",
      "transcript_url":"https://docs.google.com/document/d/11wCdqHggqcMr-1eADP_4DmBwL5hUodSjSbxtrpVCEwE/edit?tab=t.0",
      "assigned":{
         "5. 나눔복지국":"confirmed"
      }
   },
   {
      "name":"김태승",
      "applied1":"4. 대외협력국",
      "applied2":"6. 문화기획국",
      "applied3":"5. 나눔복지국",
      "comment":"뭐 그냥 뭐 쏘쏘~\n평범 평범\n소심해 보여~\n4. 3지망 국장 (나눔국)\n동생이면 기여울것 같은데 같이 일하는 사람이면 잘 모르겟당",
      "transcript_url":"https://docs.google.com/document/d/1pMUlmQOvUmflvUiAohIq6VdhI1GzopUtIGFmoQiQ7Bk/edit?tab=t.0",
      "assigned":{
         "4. 대외협력국":"confirmed"
      }
   },
   {
      "name":"장영재",
      "applied1":"3. 소통연결국",
      "applied2":"2. 재정관리국",
      "applied3":null,
      "comment":"총학생회장단 (중집위장)\n고민할 시간 달라하는거 호감인디 지금까지 많이 없었는데\n\n1지망 국장 (소통국)\n팀원으로써: 할일을 잘 하고, 팀장보다는 팀원감이라고 생각한다. 이유: 마음이 약하다…ㅠㅠ 인프피다.\n근데 뭐 준비 잘했어. \n24가 한명은 있어야 할 것 같아서 데려가고 싶다: 학교 일을 잘 아는 친구를 데려오고 싶다.\n\n총학\n2지망 국장 (재정국)\n아 좀 더 괴롭히고 싶었지만 어쩔 수 없군요\n준비 잘 해왔네\n팀원일때 더 빛난다",
      "transcript_url":"https://docs.google.com/document/d/1JW3v2GuNEz2KiusG9Ca2O4aDmEOpG9rqQiV6clYrqAo/edit?tab=t.0",
      "assigned":{
         "3. 소통연결국":"confirmed"
      }
   },
   {
      "name":"박윤서",
      "applied1":"3. 소통연결국",
      "applied2":"5. 나눔복지국",
      "applied3":"8. 미래전략실",
      "comment":"총학생회장단 (직책)\n맘에 안드는게 있었는데, 추가질문하고 ㄱㅊ아졌다. \n사람이 가벼운건지 싶었는데 아니었다.\n1지망 국장 (소통국)\n이상한 질문 많이 당했는데ㅜㅜㅜ 대답 잘했다고 생각함\n열심히 하려는 생각 많은거 같아요\n여자화장실 카드키 용으로 뽑고 싶다. \n와 아오 얘 무섭다\n\n2지망 국장 (나눔국)\n개인적으로 멘탈이 강하다고 생각함. ",
      "transcript_url":"https://docs.google.com/document/d/1-vp-LOiGqHNSUjj7wvqGJRdBx79vksqEu57DoDXwc1s/edit?tab=t.0",
      "assigned":{
         "3. 소통연결국":"confirmed"
      }
   },
   {
      "name":"엄민재",
      "applied1":"6. 문화기획국",
      "applied2":"8. 미래전략실",
      "applied3":"5. 나눔복지국",
      "comment":"총학생회장단 (직책)\n미전은 좀 쉽지 않을듯. 친목을 좋아하는 학생인듯하다. 문기가 좋을 것 같음\n\n1지망 국장 (OO국)\n확실히 미전이랑은 안맞아보임\n성격 좋은데 얼어있는듯\n온다면 문기 좋음",
      "transcript_url":"https://docs.google.com/document/d/1CMEUbvCIkFlZ8LQPNyvD-jyOEp28xdD7ckZVZ8_HxNA/edit?tab=t.0",
      "assigned":{
         "6. 문화기획국":"confirmed"
      }
   },
   {
      "name":"이정환",
      "applied1":"6. 문화기획국",
      "applied2":"4. 대외협력국",
      "applied3":null,
      "comment":"총학생회장단 (부총학)\n생각보다 재밌으려나..?\n\n1지망 국장 (문기국)\n생각보다 재밌을지도 \n근데 사회성 좀 없어보이기도 -> 레퍼체크 필요\n\n\n\n익명의 컨트롤디 부원\n엄청 밝고 장난기 많은 친구인데, 타키온즈에서 총무도 하고 뭔가 단체에서 늘 일 맡는 역할이라고 들었어요\n본인을 쓰레받이(?), 탱커, 컨디회장부회장부장선거나가서 떨어짐 -> 다 맞는 말이다\n\n2지망 국장 (대협국) 대타: 중집위장\n처음에 진짜 별로였는데 엉뚱한 모먼트가 가끔 보이는게 재밌음. \n의견: “보류” 판정",
      "transcript_url":"https://docs.google.com/document/d/1wG4wRZiUben4zA1-wRswhkpxcy75J6T8UlRAqZmqji0/edit?tab=t.0",
      "assigned":{
         "보류":"confirmed"
      }
   }
]

# --- 데이터 로딩 함수 ---
def load_candidates_from_excel(filename: str = "data.xlsx") -> List[Dict]:
    """
    엑셀 파일에서 지원자 데이터를 로드하고 'assigned' 필드를 초기화합니다.
    파일이 없거나 로드에 실패하면 더미 데이터를 반환합니다.
    """
    print(f"Loading data from {filename}...")
    
    if not os.path.exists(filename):
        print(f"Error: {filename} not found. Using dummy data.")
        return DUMMY_CANDIDATES

    try:
        # 데이터 타입을 명시하고 NaN 값을 None으로 치환
        df = pd.read_excel(
            filename, 
            dtype={
                'name': str, 'applied1': str, 'applied2': str, 
                'applied3': str, 'comment': str, 'transcript_url': str
            }
        )
        
        # 'applied3' 필드의 NaN을 None으로 처리
        df = df.replace({np.nan: None})
        
        candidates = []
        for index, row in df.iterrows():
            candidate_data = {
                "name": row["name"],
                "applied1": row["applied1"],
                "applied2": row["applied2"],
                "applied3": row["applied3"],
                "comment": row["comment"],
                "transcript_url": row["transcript_url"],
                "assigned": {} # 'assigned' 필드는 초기화
            }
            candidates.append(candidate_data)
        
        if not candidates:
            print(f"Warning: {filename} is empty. Using dummy data.")
            return DUMMY_CANDIDATES

        print(f"Successfully loaded {len(candidates)} candidates from {filename}.")
        return candidates

    except Exception as e:
        print(f"Failed to load Excel file: {e}. Using dummy data.")
        return DUMMY_CANDIDATES


# --- 데이터베이스 초기화 (엑셀 파일에서 로드 시도) ---
candidates_db = load_candidates_from_excel("data.xlsx")
# ---------------------------------------------


@app.get("/candidates")
async def get_candidates():
    return candidates_db

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        await self.send_current_status(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def send_current_status(self, websocket: WebSocket):
        status = [{"name": c["name"], "assigned": c["assigned"]} for c in candidates_db]
        await websocket.send_text(json.dumps(status))

    async def broadcast_status(self):
        status = [{"name": c["name"], "assigned": c["assigned"]} for c in candidates_db]
        message = json.dumps(status)
        for connection in self.active_connections:
            await connection.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            payload = json.loads(data)
            
            target_name = payload.get("name")
            target_dept = payload.get("department")
            target_status = payload.get("status") # "confirmed" or "candidate"
            
            if target_name and target_dept:
                for candidate in candidates_db:
                    if candidate["name"] == target_name:
                        current_assigned = candidate["assigned"]
                        
                        if target_dept in current_assigned and current_assigned[target_dept] == target_status:
                            del current_assigned[target_dept]
                        else:
                            current_assigned[target_dept] = target_status
                        break
                
                await manager.broadcast_status()
                
    except WebSocketDisconnect:
        manager.disconnect(websocket)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)