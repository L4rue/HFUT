### 合肥工业大学形势与政策网课(hfut.xuetangx.com)题目获取&&答案查询脚本  
  
需要自己设置一下get_question()函数中的cookie和data信息，在试卷页面按F12后刷新，位于network中XHR标签下的subject里的headers，cookie在request headers中，data在request payload中，每次更换data即可；  
理论上文化概论、近代史、毛概等课程也可以用，主要看查答案的网站是否支持。


>npm install crypto-js  
pip install PyExecJS  
pip install lxml  

get_answer1不用额外装东西，但是那个网站经常挂掉，不太稳定，后两个比较稳定；  
get_answer2用到了lxml，get_answer3用到了PyExecJS，和node.js；按需安装  

具体方法自行百度

由于考试是分页的，所以需要分两次获取题目信息。  
两个链接大概这个样子，“\*”自行替换：
>https://hfut.xuetangx.com/api/paper/subject/E+*****+****/E+*****+****-**/?offset=0&limit=50&type=1
https://hfut.xuetangx.com/api/paper/subject/E+*****+****/E+*****+****-**/?offset=50&limit=50&type=1
