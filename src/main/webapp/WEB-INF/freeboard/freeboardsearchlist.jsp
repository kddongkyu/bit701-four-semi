<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../commonvar.jsp" %>




<script>

    // 몇시간전글인지
    function timeForToday(value) {
        const valueConv = value.slice(0, -2);
        const today = new Date();
        const timeValue = new Date(valueConv);

        const betweenTime = Math.floor((today.getTime() - timeValue.getTime()) / 1000 / 60);
        if (betweenTime < 1) return '방금전';
        if (betweenTime < 60) {
            return `\${betweenTime}분전`;
        }

        const betweenTimeHour = Math.floor(betweenTime / 60);
        if (betweenTimeHour < 24) {
            return `\${betweenTimeHour}시간전`;
        }

        const betweenTimeDay = Math.floor(betweenTime / 60 / 24);
        if (betweenTimeDay < 7) {
            return `\${betweenTimeDay}일전`;
        }

        const month = String(timeValue.getMonth() + 1).padStart(2, '0');
        const day = String(timeValue.getDate()).padStart(2, '0');
        const formattedDate = `\${month}-\${day}`;

        return `\${formattedDate}`;
    }


    $(document).ready(function () {

        var currentpage = 1;
        var isLoading = false;
        var noMoreData = false;
        var keyword = "${keyword}";
        console.log(keyword);

        $(window).scroll(function () {
            console.log(Math.floor($(window).scrollTop()) == $(document).height() - $(window).height());

            // 무한스크롤
            if (Math.floor($(window).scrollTop()) == $(document).height() - $(window).height()) {

                if (!isLoading && !noMoreData) {
                    isLoading = true;
                    var nextPage = currentpage + 1;

                    $.ajax({
                        type: "GET",
                        url: "./searchlistajax",
                        data: {"keyword": keyword, "searchOption": "all", "currentpage": nextPage},
                        beforeSend: function () {
                            $("#loading").show();
                        },
                        complete: function () {
                            isLoading = false;
                        },
                        success: function (res) {

                            if (res.searchCount == 0) {
                                $(".listbox").append(`<h2 class="alert alert-outline-secondary">등록된 게시글이 없습니다..</h2>`);
                                $("#loading").hide();
                            } else {
                                if (res.length == 0) {
                                    noMoreData = true;
                                    $("#loading").hide();
                                } else {
                                    setTimeout(function () {
                                        currentpage++;
                                        var s = '';
                                        $.each(res, function (idx, dto) {
                                            if (dto.fb_dislike > 19) {
                                                if (idx % 2 == 1) {
                                                    s += `<div class="blurbox" style="border-left: 1px solid #eee;padding-right: 0px;padding-left: 20px;">`;
                                                } else {
                                                    s += `<div class="blurbox">`;
                                                }
                                            } else {
                                                if (idx % 2 == 1) {
                                                    s += `<div class="box" style="border-left: 1px solid #eee;padding-right: 0px;padding-left: 20px;">`;
                                                } else {
                                                    s += `<div class="box">`;
                                                }
                                            }
                                            s += `<span class="fb_writeday">\${dto.fb_writeday}</span>`
                                            s += `<span class="fb_readcount"><div class="icon_read"></div>\${dto.fb_readcount}</span><br><br>`;
                                            s += `<span class="nickName" style="cursor:pointer;" onclick=message("\${dto.nickName}")><img src="\${dto.m_photo}" class="memberimg">&nbsp;
\${dto.nickName}</span>`;
                                            s += `<div class="mainbox">`
                                            s += `<h3 class="fb_subject"><a href="freeboarddetail?fb_idx=\${dto.fb_idx}"><b>\${dto.fb_subject}</b></a></h3>`;
                                            if (dto.fb_photo == 'n') {
                                                var content = dto.fb_content.substring(0, 120);
                                                if (dto.fb_content.length >= 120) {
                                                    content += ".....";
                                                }
                                                s += `<h5 class="fb_content" style="width: 90%"><a href="freeboarddetail?fb_idx=\${dto.fb_idx}" style="color: #000;"><span>\${content}</span></a></h5>`;
                                            } else {
                                                var content = dto.fb_content.substring(0, 80);
                                                if (dto.fb_content.length >= 80) {
                                                    content += ".....";
                                                }
                                                s += `<h5 class="fb_content" style="width:80%"><a href="freeboarddetail?fb_idx=\${dto.fb_idx}" style="color: #000;"><span class="photocontent">\${content}</span></a></h5>`;
                                                s += `<div style="position:relative; right:0; top: -80px;"><a href="freeboarddetail?fb_idx=\${dto.fb_idx}" style="color: #000;"><span class="fb_photo"><img src="http://${imageUrl}/freeboard/\${dto.fb_photo.split(",")[0]}" id="fb_photo"></span></a></div>`;
                                            }
                                            s += `<div class="hr_tag"><div class="hr_tag_1"><i class="bi bi-hand-thumbs-up"></i>&nbsp;\${dto.fb_like}&nbsp;&nbsp;<i class="bi bi-hand-thumbs-down"></i>&nbsp;\${dto.fb_dislike}</div><div class="hr_tag_2"><i class="bi bi-chat"></i>&nbsp;\${dto.commentCnt}</div></div>`;
                                            s += `</div>`;
                                            s += `</div>`;
                                        })
                                        $(".listbox").append(s);
                                        $("#loading").hide();
                                    }, 1000);  // 1초 후에 실행
                                }
                            }
                        },
                        error: function (xhr, status, error) {
                            console.log("Error:", error);
                            $("#loading").hide();
                        }

                    })
                }
            }


        });


    });

    // When the user scrolls down 20px from the top of the document, show the button
    window.onscroll = function () {
        scrollFunction()
    };

    function scrollFunction() {
        if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
            document.getElementById("myBtn").style.display = "block";
        } else {
            document.getElementById("myBtn").style.display = "none";
        }
    }


    // When the user clicks on the button, scroll to the top of the document
    function topFunction() {
        document.body.scrollTop = 0; // For Safari
        document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
    }

    // 프로필 클릭
    function message(nickname) {
        window.open("other_profile?other_nick=" + nickname, 'newwindow', 'width=700,height=700');
    }



</script>


<div class="fb_wrap">

    <!--===============================Headbox==============================================-->

    <div class="headbox" style="display: unset">
        <h4 class="boardname">
            <div class="yellowbar">&nbsp;</div>&nbsp;&nbsp;일반게시판
        </h4><br><br>

        <!-- 검색결과 -->
        <div class="searchres">
           <h5>&nbsp;<b>${keyword}</b>&nbsp;검색결과 : 전체 (${searchCount})</h5>
        </div>
    </div>

    <!--=============================================================================-->

    <!-- listbox -->
    <div class="listbox">
        <c:if test="${searchCount==0}">
            <h2 class="alert alert-outline-secondary">등록된 게시글이 없습니다..</h2>
        </c:if>

        <c:if test="${searchCount>0}">
            <c:forEach var="dto" items="${list}" varStatus="i">
                <!-- blurbox-->
                <c:if test="${dto.fb_dislike > 19}">
                    <div class="blurbox"
                         <c:if test="${i.index % 2 == 1}">style="border-left: 1px solid #eee;padding-right: 0px;padding-left: 20px;"</c:if>>

                        <span class="fb_writeday" id="writeday-${dto.fb_idx}"></span>
                        <script>
                            var writedayElement = document.getElementById("writeday-${dto.fb_idx}");
                            var formattedWriteday = timeForToday("${dto.fb_writeday}");
                            writedayElement.textContent = formattedWriteday;
                        </script>

                        <span class="fb_readcount"><div class="icon_read"></div>
                                ${dto.fb_readcount}</span><br><br>

                        <span class="nickName" style="cursor:pointer;" onclick=message("${dto.nickName}")><img
                                src="${dto.m_photo}"
                                class="memberimg">&nbsp;&nbsp;${dto.nickName}</span>

                        <div class="mainbox">
                            <h3 class="fb_subject">
                                <a href="freeboarddetail?fb_idx=${dto.fb_idx}"><b>${dto.fb_subject}</b></a>
                            </h3>

                            <c:if test="${dto.fb_photo=='n'}">
                                <h5 class="fb_content" style="width: 90%">
                                    <a href="freeboarddetail?fb_idx=${dto.fb_idx}"
                                       style="color: #000;">
                                <span>
                                    <c:set var="length" value="${fn:length(dto.fb_content)}"/>
                                    ${fn:substring(dto.fb_content, 0, 120)}

                                    <c:if test="${length>=120}">
                                        .....
                                    </c:if>
                                   </span></a>
                                </h5>
                            </c:if>
                            <c:if test="${dto.fb_photo!='n'}">
                                <h5 class="fb_content" style="width: 80%;">
                                    <a href="freeboarddetail?fb_idx=${dto.fb_idx}"
                                       style="color: #000;">
                                <span class="photocontent">
                                    <c:set var="length" value="${fn:length(dto.fb_content)}"/>
                                    ${fn:substring(dto.fb_content, 0, 80)}

                                    <c:if test="${length>=80}">
                                        .....
                                    </c:if>
                                   </span>
                                    </a>
                                </h5>
                                <div style="position:relative; right:0; top: -80px;">
                                    <a href="freeboarddetail?fb_idx=${dto.fb_idx}">
                                    <span class="fb_photo">
                    <img src="http://${imageUrl}/freeboard/${dto.fb_photo.split(",")[0]}" id="fb_photo">
                        </span>
                                    </a>
                                </div>

                            </c:if>

                            <div class="hr_tag">
                                <div class="hr_tag_1"><i class="bi bi-hand-thumbs-up"></i>&nbsp;${dto.fb_like}&nbsp;&nbsp;<i
                                        class="bi bi-hand-thumbs-down-"></i>&nbsp;${dto.fb_dislike}</div>
                                <div class="hr_tag_2"><i class="bi bi-chat"></i>&nbsp;${dto.commentCnt}</div>
                            </div>

                        </div>

                    </div>


                </c:if>
                <!-- blurbox-->
                <!-- box-->
                <c:if test="${dto.fb_dislike < 20}">
                    <div class="box"
                         <c:if test="${i.index % 2 == 1}">style="border-left: 1px solid #eee;padding-right: 0px;padding-left: 20px;"</c:if>>

                        <span class="fb_writeday" id="writeday-${dto.fb_idx}"></span>
                        <script>
                            var writedayElement = document.getElementById("writeday-${dto.fb_idx}");
                            var formattedWriteday = timeForToday("${dto.fb_writeday}");
                            writedayElement.textContent = formattedWriteday;
                        </script>

                        <span class="fb_readcount"><div class="icon_read"></div>
                                ${dto.fb_readcount}</span><br><br>

                        <span class="nickName" style="cursor:pointer;" onclick=message("${dto.nickName}")><img
                                src="${dto.m_photo}"
                                class="memberimg">&nbsp;${dto.nickName}</span>

                        <div class="mainbox">
                            <h3 class="fb_subject">
                                <a href="freeboarddetail?fb_idx=${dto.fb_idx}"><b>${dto.fb_subject}</b></a>
                            </h3>

                            <c:if test="${dto.fb_photo=='n'}">
                                <h5 class="fb_content" style="width: 90%">
                                    <a href="freeboarddetail?fb_idx=${dto.fb_idx}"
                                       style="color: #000;">
                                <span>
                                    <c:set var="length" value="${fn:length(dto.fb_content)}"/>
                                    ${fn:substring(dto.fb_content, 0, 120)}

                                    <c:if test="${length>=120}">
                                        .....
                                    </c:if>
                                   </span></a>
                                </h5>
                            </c:if>
                            <c:if test="${dto.fb_photo!='n'}">
                                <h5 class="fb_content">
                                    <a href="freeboarddetail?fb_idx=${dto.fb_idx}"
                                       style="color: #000;">
                                <span class="photocontent">
                                    <c:set var="length" value="${fn:length(dto.fb_content)}"/>
                                    ${fn:substring(dto.fb_content, 0, 80)}

                                    <c:if test="${length>=80}">
                                        .....
                                    </c:if>
                                   </span>
                                    </a>
                                </h5>
                                <div style="position:relative; right:0; top: -80px;">
                                    <a href="freeboarddetail?fb_idx=${dto.fb_idx}">
                                <span class="fb_photo">
                    <img src="http://${imageUrl}/freeboard/${dto.fb_photo.split(",")[0]}" id="fb_photo">
            </span>
                                    </a>
                                </div>

                            </c:if>

                            <div class="hr_tag">
                                <div class="hr_tag_1"><i class="bi bi-hand-thumbs-up"></i>&nbsp;${dto.fb_like}&nbsp;&nbsp;<i
                                        class="bi bi-hand-thumbs-down"></i>&nbsp;${dto.fb_dislike}</div>
                                <div class="hr_tag_2"><i class="bi bi-chat"></i>&nbsp;${dto.commentCnt}</div>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- box-->
            </c:forEach>
        </c:if>
    </div>
    <!-- listbox -->
    <div id="loading"
         style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); z-index: 9999;">
        <img src="${root}/photo/loading.gif" alt="Loading..."
             style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);">
        <!-- 로딩 이미지의 경로를 설정하세요 -->
    </div>

    <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
    <br>
    <button id="myWriteBtn" type="button" onclick="location.href='./freewriteform'">글쓰기</button>


</div>