
<%--
  Created by IntelliJ IDEA.
  User: JuminManeul
  Date: 2023-05-02
  Time: 오후 4:05
  To change this template use File | Settings | File Templates.
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="root" value="<%=request.getContextPath()%>" />

<style>
    .black_bar{
        padding-left: 30px;
    }
    .black_bar .btn_hub {
        display: inline-block;
        margin-top: 11px;
    }

    .black_bar .btn_hub .icon_hub {
        display: inline-block;
        width: 20px;
        height: 20px;
        margin-right: 4px;
        vertical-align: top;
        background: url(https://static.teamblind.com/img/www_kr/sp-kr.png) no-repeat;
        background-size: 600px 900px;
        background-position: -340px -484px;
    }

    .black_bar .btn_hub  .txt {
        position: relative;
        padding-right: 16px;
        font-size: 14px;
        color: #fff;
        line-height: 17px;
        vertical-align: top;
    }

    .black_bar .btn_hub  .txt strong{
        font-weight: bold;
    }

</style>



<script>
    $(document).ready(function (){
        getCount();
    });
</script>

<div class="black_bar">
    <a href="/" class="btn_hub">
        <span class="icon_hub"></span>
        <span class="txt"><strong>Devster</strong> 커뮤니티 서비스</span>
    </a>

</div>
<div class="wrap clear">
    <div class="logo">
        <a href="${root}/"> <img src="/photo/logo.png" class="logotext">
            <span><img src="/photo/logoimage.png" class="logoimage"></span>
        </a>
    </div>
    <ul class="clear gnb">

        <li><a id="home" href="${root}/" class="selected">홈</a></li>
        <li><a id="free" href="${root}/freeboard/list">일반게시판</a></li>
        <li><a id="qna" href="${root}/qboard/list">질문게시판</a></li>
        <li><a id="hire" href="${root}/hire/list">채용정보</a></li>
        <li><a id="academy"

                <c:if test="${sessionScope.cmidx != null}">
                    onclick="alert('기업회원은 열람하실 수 없습니다.')"
                </c:if>
                <c:if test="${sessionScope.cmidx == null}">
                    href="${root}/academyboard/list"
                </c:if>
        >학원별게시판</a></li>
        <li><a id="review" href="${root}/review/list">회사후기</a></li>
        <%--<li><a id="notice" href="${root}/noticeboard/list">공지사항</a></li>--%>
    </ul>
    <c:choose>
        <c:when test="${sessionScope.logstat == 'yes'}">
            <ul class="clear util_menu">
                <li><button type="button" class="btn btnsignup" onclick="location.href='/mypage/'">마이페이지</button></li>
                <li><button type="button" class="btn btnsignin" onclick="location.href='/member/outtest'">로그아웃</button></li>
                <li class="message_box">
                </li>

            </ul>
        </c:when>
        <c:otherwise>
            <ul class="clear util_menu">
                <li><button type="button" class="btn btnsignup" onclick="location.href='../member/selmember'">회원가입</button></li>
                <li><button type="button" class="btn btnsignin" onclick="location.href='../member/signin'">로그인</button></li>
            </ul>
        </c:otherwise>
    </c:choose>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const currentPath = window.location.pathname;
        const navLinks = document.querySelectorAll(".gnb li a");

        navLinks.forEach((link) => {
            if (link.getAttribute("href") === currentPath) {
                link.classList.add("selected");
            } else {
                link.classList.remove("selected");
            }
        });
    });

    //메세지 갯수 확인 ---------------------------------------------

    function getCount(){
        $.ajax({
            type : "post",
            url : "/messagecount",
            dataType : "json",
            success :function (res){
                let s = "";
                if(res == 0 ) {
                    s+=`
                    <a href="${root}/message/list">
                    <div class="message_count_alarm"></div>
                    <div class="message_count_text">0</div>
                        <i class="bi bi-envelope"></i>
                    </a>`;
                } else {
                    s+= `
                    <div class="message_count_text">\${res}</div>
                    <a href="${root}/message/list">
                        <div class="message_count_alarm" style = "background-color : red;"></div>
                        <div class="message_count_text">\${res}</div>
                        <i class="bi bi-envelope"></i>
                    </a>`;
                }
                $(".message_box").html(s);
            }

        });
    }

    // 회원권한관리------------------------------------------------
    // 비로그인 상태 (sessionScope.logstat != yes)
    if(${sessionScope.logstat!='yes'}){

        $(".gnb a#free").click(function (){
            alert("로그인 후 이용가능한 기능입니다.");
            location.href='../member/signin';
            return false;
        });
        $(".gnb a#notice").click(function (){
            alert("로그인 후 이용가능한 기능입니다.");
            location.href='../member/signin';
            return false;
        });
        $(".gnb a#qna").click(function (){
            alert("로그인 후 이용가능한 기능입니다.");
            location.href='../member/signin';
            return false;
        });
        $(".gnb a#hire").click(function (){
            alert("로그인 후 이용가능한 기능입니다.");
            location.href='../member/signin';
            return false;
        });
        $(".gnb a#academy").click(function (){
            alert("로그인 후 이용가능한 기능입니다.");
            location.href='../member/signin';
            return false;
        });
        $(".gnb a#review").click(function (){
            alert("로그인 후 이용가능한 기능입니다.");
            location.href='../member/signin';
            return false;
        });

    }
    // 인증 안된 회원 (sessionScope.memstate == 0)
    if(${sessionScope.memstate==0}){

        $(".qboard_table a").click(function (){
            alert("인증 후 이용가능한 기능입니다.");
            location.href='/';
            return false;
        });
        $(".gnb a#qna").click(function (){
            alert("인증 후 이용가능한 기능입니다.");
            location.href='/';
            return false;
        });
        $(".gnb a#hire").click(function (){
            alert("인증 후 이용가능한 기능입니다.");
            location.href='/';
            return false;
        });
        $(".gnb a#academy").click(function (){
            alert("인증 후 이용가능한 기능입니다.");
            location.href='/';
            return false;
        });
        $(".gnb a#review").click(function (){
            alert("인증 후 이용가능한 기능입니다.");
            location.href='../member/signin';
            return false;
        });

    }
</script>
<%--</body>
</html>--%>
