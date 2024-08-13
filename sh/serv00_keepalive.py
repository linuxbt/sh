# -*- coding: utf-8 -*-
import mechanize
from html.parser import HTMLParser

class MyHTMLParser(HTMLParser):
    def __init__(self, username):
        super().__init__()
        self.username = username
        self.success = False

    def handle_data(self, data):
        if f'Zalogowany jako: {self.username}' in data:
            self.success = True

# 替换为实际的网站和登录参数
login_url = 'https://panel9.serv00.com/login/'
username = 'admin'
password = 'admin'

# 创建一个浏览器对象
br = mechanize.Browser()
br.set_handle_robots(False)   # 忽略 robots.txt

# 设置 User-Agent 头部
br.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36')]

# 打开登录页面
response = br.open(login_url)

# 选择登录表单
br.select_form(nr=1)

# 填写表单，注意这里使用的是输入框的 name 属性
br['username'] = username
br['password'] = password

# 提交表单
response = br.submit()

# 使用自定义的 HTML 解析器验证登录是否成功
parser = MyHTMLParser(username)
parser.feed(response.read().decode())

if parser.success:
    print("Login successful")
else:
    print("Login failed")
