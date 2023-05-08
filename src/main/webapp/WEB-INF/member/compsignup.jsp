<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../commonvar.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Insert title here</title>
    <script src="https://code.jquery.com/jquery-3.6.3.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Gamja+Flower&family=Jua&family=Lobster&family=Nanum+Pen+Script&family=Single+Day&display=swap"
          rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <style>
        #reseticon {
            display: none;
            cursor: pointer;
        }

        .emailreg {
            display: none;
        }
    </style>
</head>
<body>
<div style="width : 500px;">
    <div>
        <strong>이메일</strong>
        <input type="email" id="cm_email" required placeholder="email@example.com">
        <span id="emailchkicon"></span>
        
    </div>
    <div class="input-group emailchk">
        <strong>이메일</strong>
        <button type="button" id="sendemail" disabled>인증요청</button>
        <i class="bi bi-arrow-clockwise" id="reseticon"></i>
    </div>
    <div class="inputgroup emailreg">
        <label id="timer"></label>
        <input type="text" id="eregnumber">
        <button type="button" id="eregbtn"><span>확인</span></button>
    </div>
</div>
<script>
    let emailvalid = false;
    let emailcheck = false;

    //emailcheck
    $("#cm_email").keyup(function () {
        let cm_email = $(this).val();
        if (!validEmail(cm_email)) {
            $("#emailchkicon").html("<i class='bi bi-x' style='color:red;'></i>" +
                "<span>옳바른 이메일 형식을 써주세요</span>");
            emailvalid = false;
        } else {
            $.ajax({
                type: "get",
                url: "cmemailchk",
                dataType: "json",
                data: {"cm_email": cm_email},
                success: function (res) {
                    if (res.result == "yes") {
                        $("#emailchkicon").html("<i class='bi bi-check' style='color:green;'></i>" +
                            "<span>사용가능한 E-mail입니다</span>");
                        emailcheck = true;
                    } else {
                        $("#sendemail").prop("disabled", true);
                        $("#emailchkicon").html("<i class='bi bi-x' style='color:red;'></i>" +
                            "<span>이미 사용중인 E-mail입니다</span>");
                        emailcheck = false;
                    }
                }
            });
            emailvalid = true;
        }
    });
    
    //timer
    let timer = null;
    let proc = false;

    function startTimer(count, display) {
        let min, sec;
        timer = setInterval(function () {
            min = parseInt(count / 60, 10);
            sec = parseInt(count % 60, 10);

            min = min < 10 ? "0" + min : min; //0붙이기
            sec = sec < 10 ? "0" + sec : sec;

            display.html(min + ":" + sec);

            //타이머 끝
            if (--count < 0) {
                clearInterval(timer);
                display.html("시간초과");
                $("#eregbtn").prop("disabled", true);
                proc = false;
            }
        }, 1000);
        proc = true;
    }

    //setup
    let display = $("#timer");
    let timeleft = 30;

    //email check
    $(document).on("keyup", "#cm_email", function () {
        let email = $("#cm_email").val();
        if (!validEmail(email)) {
            $("#sendemail").prop("disabled", true);
        } else {
            $("#sendemail").prop("disabled", false);
        }
    });

    //reset email
    btncnt = 0;
    $(document).on("click", "#reseticon", function () {
        if (btncnt < 2) {
            $.ajax({
                type: "get",
                url: "resetcheck",
                cache: false,
                success: function (res) {
                    if (res == "yes") {
                        let b = confirm("인증 중 이메일을 수정하면 현재 발송된 인증번호는\n더이상 사용하실 수 없습니다. 그래도 수정하시겠어요?");
                        if (b) {
                            clearInterval(timer);
                            display.html("");
                            $("#eregnumber").val("");
                            $("#reseticon").hide();
                            $(".emailreg").hide();
                            $("#sendemail").text("인증요청");
                            $("#cm_email").prop("readonly", false);
                            $("#eregbtn").prop("disabled",false);
                            ecnt = 0;
                            btncnt++;
                            emailcheck = false;
                        }
                    } else {
                        alert("수정 횟수를 초과하셨습니다\n잠시후 다시 시도해주세요");
                        return false;
                    }
                }
            });
        } else {
            alert("수정 횟수를 초과하셨습니다\n잠시후 다시 시도해주세요");
            $.ajax({
                type: "get",
                url: "blockreset",
                cache: false,
                success: function (res) {
                }
            });
            return false;
        }
    });

    let ecode = "";
    let ecnt = 0;
    $(document).on("click", "#sendemail", function () {
        $("#cm_email").prop("readonly", true);
        let email = $("#cm_email").val();
        display = $("#timer");
        timeleft = 30;
        if (ecnt == 0) {
            $.ajax({
                type: "get",
                url: "blockcheck",
                cache: false,
                success: function (res) {
                    if (res == "yes") {
                        alert("인증번호가 발송되었습니다");
                        $.ajax({
                            type: "get",
                            url: "sendemail?email=" + email,
                            cache: false,
                            success: function (res) {
                                ecode = res;
                                ecnt++;
                                console.log(ecnt);
                            }
                        });
                        $("#reseticon").show();
                        $(".emailreg").show();
                        $("#sendemail").text("재발송");

                        if (proc) {
                            clearInterval(timer);
                            display.html("");
                            startTimer(timeleft, display);
                        } else {
                            startTimer(timeleft, display);
                        }
                    } else {
                        alert("인증번호 발급횟수를 초과하셨습니다\n잠시후 다시 시도해주세요");
                        return false;
                    }
                }
            });
        } else if (ecnt > 0 && ecnt < 3) {
            let b = confirm("정말 인증번호를 다시 받으시겠습니까?\n기존의 번호는..");
            if (b) {
                $("#eregbtn").prop("disabled",false);
                let email = $("#cm_email").val();
                alert("인증번호가 발송되었습니다");
                $.ajax({
                    type: "get",
                    url: "sendemail?email=" + email,
                    cache: false,
                    success: function (res) {
                        ecnt++;
                        ecode = res;
                        console.log(ecnt);

                        if (proc) {
                            clearInterval(timer);
                            display.html("");
                            startTimer(timeleft, display);
                        } else {
                            startTimer(timeleft, display);
                        }
                    }
                });
            }
        } else {
            alert("인증번호 발급횟수를 초과하셨습니다\n잠시후 다시 시도해주세요");
            $.ajax({
                type: "get",
                url: "blocksend",
                cache: false,
                success: function (res) {
                }
            });
            return false;
        }
    });

    $(document).on("click", "#eregbtn", function () {
        if ($("#eregnumber").val() == ecode) {
            alert("인증 되었습니다");
            clearInterval(timer);
            display.html("");
            $("#eregnumber").prop("readonly", true);
            $("#sendemail").prop("disabled", true);
            $("#eregbtn").prop("disabled", true);
            $("#reseticon").hide();
            emailcheck = true;
        } else {
            alert("인증 번호 틀림");
            $("#eregnumber").val("");
            $("#eregnumber").focus();
            emailcheck = false;
        }
    });

    //email pattern
    function validEmail(email) {
        let emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        return emailPattern.test(email);
    }
</script>
</body>
</html>

