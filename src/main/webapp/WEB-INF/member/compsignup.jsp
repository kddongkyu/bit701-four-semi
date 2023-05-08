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
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
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
    <div>
        <strong>비밀번호</strong>
        <input type="password" id="cm_pass" required placeholder="8~16자리/영문 대소문자, 숫자, 특수문자 조합">
        <span id="passokicon"></span>
        <b>비밀번호확인</b>
        <input type="password" id="passchk" placeholder="8~16자리/영문 대소문자, 숫자, 특수문자 조합">
        <span id="passchkicon"></span>
    </div>
    <div>
        <strong>회사명</strong>
        <input type="text" id="cm_compname">
        <span id="compnamechkicon"></span>
    </div>
    <div>
        <div class="input-group">
            <strong>우편번호</strong>
            <input type="text" id="cm_post" readonly>
            <button type="button" id="postbtn">우편번호 찾기</button>
        </div>
        <strong>주소</strong>
        <input type="text" id="addr" readonly>
        <strong>상세주소</strong>
        <input type="text" id="addrinfo">
    </div>
    <div>
        <strong>전화번호</strong>
        <input type="tel" id="cm_tele">
    </div>
    <div>
        <strong>담당자</strong>
        <input type="text" id="cm_name">
        <strong>휴대폰</strong>
        <input type="tel" id="cm_cp">
    </div>
</div>
<script>
    let emailvalid = false;
    let emailcheck = false;
    let passvalid = false;
    let passcheck = false;
    let compname = false;
    let compvalid = false;

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
                            $("#eregbtn").prop("disabled", false);
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
                $("#eregbtn").prop("disabled", false);
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

    //pass check
    function updatePasswordStatus() {
        let pass = $("#cm_pass").val();
        let passMatch = $("#passchk").val();
        let valid = validPass(pass);

        if (valid) {
            $("#passokicon").html("<i class='bi bi-check' style='color:green;'></i>" +
                "<span>사용 가능한 비밀번호에요</span>");
            passvalid = true;
        } else {
            $("#passokicon").html("<i class='bi bi-x' style='color:red;'></i>" +
                "<span>8~16자리 영문 대소문자, 숫자, 특수문자의 조합으로 만들어주세요</span>");
            passvalid = false;
        }

        if (pass != passMatch) {
            $("#passchkicon").html("<i class='bi bi-x' style='color:red;'></i>" +
                "<span>비밀번호와 일치하지 않아요</span>");
            passcheck = false;
        } else {
            $("#passchkicon").html("<i class='bi bi-check' style='color:green;'></i>" +
                "<span>비밀번호와 일치해요</span>");
            passcheck = true;
        }

        if (pass == "" && passMatch == "") {
            $("#passchkicon").html("");
        }
    }

    $("#cm_pass").keyup(function () {
        updatePasswordStatus();
    });

    $("#passchk").keyup(function () {
        updatePasswordStatus();
    });

    function validPass(pass) {
        let passPattern = /^[a-zA-Z0-9!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]+$/;
        return pass.length >= 8 && pass.length <= 16 && passPattern.test(pass);
    }

    //compname check
    $("#cm_compname").keyup(function () {
        let cm_compname = $(this).val();
        if (!validCompname(cm_compname)) {
            $("#compnamechkicon").html("<i class='bi bi-x' style='color:red;'></i>" +
                "<span>한글,영문과 숫자만 사용해주세요</span>");
            compvalid = false;
        } else {
            $.ajax({
                type: "get",
                url: "compnamechk",
                dataType: "json",
                data: {"cm_compname": cm_compname},
                success: function (res) {
                    if (res.result == "no") {
                        $("#compnamechkicon").html("<i class='bi bi-check' style='color:green;'></i>" +
                            "<span>사용가능한 회사명입니다</span>");
                        $("#cm_compname").css({"border": "1px solid black", "box-shadow": "none"});
                        compname = true;
                    } else {
                        $("#compnamechkicon").html("<i class='bi bi-x' style='color:red;'></i>" +
                            "<span>이미 사용중인 회사명입니다</span>");
                        $("#cm_compname").css({"border": "1px solid red", "box-shadow": "none"});
                        compname = false;
                    }
                }
            });
            compvalid = true;
        }
    });

    function validCompname(compname) {
        let compNamePattern = /^[a-zA-Z0-9가-힣]{1,}$/;
        return compNamePattern.test(compname);
    }

    //kakao addr api
    window.onload = function () {
        $("#postbtn").click(function () {
            new daum.Postcode({
                oncomplete: function (data) {
                    $("#cm_post").val(data.zonecode);
                    $("#addr").val(data.address);
                    $("#addrinfo").focus();
                }
            }).open();
        });
    }
</script>
</body>
</html>

