package devster.semi.controller;


import devster.semi.dto.FreeBoardDto;
import devster.semi.dto.HireBoardDto;
import devster.semi.mapper.HireMapper;
import devster.semi.service.HireService;
import naver.cloud.NcpObjectStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;


@Controller
@RequestMapping("/hire")
public class HireBoardController {

    @Autowired
    private HireService hireService;

    @Autowired
    HireMapper hireMapper;

    @Autowired
    private NcpObjectStorageService storageService;

    //버켓이름지정
    private String bucketName="devster-bucket";//각자 자기 버켓이름


    @GetMapping("/list")
    public String list(@RequestParam(defaultValue = "1") int currentPage, Model model)

    {

//        System.out.println(currentPage);
        int totalCount = hireService.getHireTotalCount();
        int totalPage; // 총 페이지 수
        int perPage = 10; // 한 페이지당 보여줄 글 갯수
        int perBlock = 10; // 한 블록당 보여질 페이지의 갯수
        int startNum; // 각 페이지에서 보여질 글의 시작번호
        int startPage; // 각 블록에서 보여질 시작 페이지 번호
        int endPage; // 각 블록에서 보여질 끝 페이지 번호
        int no; // 글 출력시 출력할 시작번호

        // 총 페이지 수
        totalPage = totalCount / perPage + (totalCount % perPage == 0 ? 0 : 1);
        // 시작 페이지
        startPage = (currentPage - 1) / perBlock * perBlock + 1;
        // 끝 페이지
        endPage = startPage + perBlock - 1;

        // endPage가 totalPage 보다 큰 경우
        if (endPage > totalPage)
            endPage = totalPage;

        // 각 페이지의 시작번호 (1페이지: 0, 2페이지 : 3, 3페이지 6 ....)
        startNum = (currentPage - 1) * perPage;

        // 각 글마다 출력할 글 번호 (예 : 10개일 경우 1페이지 10, 2페이지 7...)
        // no = totalCount - (currentPage - 1) * perPage;
        no = totalCount - startNum;

        // 각 페이지에 필요한 게시글 db에서 가져오기
        List<HireBoardDto> list = hireService.getHirePagingList(startNum, perPage);


//        List<HireBoardDto> list=hireMapper.getAllPosts();
        //model 에 저장
        model.addAttribute("currentPage",currentPage);
        model.addAttribute("list", list);
//        model.addAttribute("pagelist", pagelist);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("startPage", startPage);
        model.addAttribute("endPage", endPage);
        model.addAttribute("totalPage", totalPage);
        model.addAttribute("no", no);


        return "/main/hire/hirelist";
    }

    @GetMapping("/form")
    public String form(@RequestParam(defaultValue = "1") int currentPage,
                       @RequestParam(defaultValue = "0") int hb_idx, Model model){

        model.addAttribute("currentPage",currentPage);
        model.addAttribute("hb_idx",hb_idx);

        return "/main/hire/hireform";
    }


    @PostMapping("/insertHireBoard")

    public String insert(HireBoardDto dto,List<MultipartFile> upload)
    {
        String hb_photo="";
        if(upload.get(0).getOriginalFilename().equals("")){
            hb_photo="no";

        } else{
            int i=0;
            for(MultipartFile mfile : upload) {
//            hb_photo = storageService.uploadFile(bucketName,"hire",upload);

            //사진 업로드.
            hb_photo += (storageService.uploadFile(bucketName, "hire", mfile) + ",");
            }
        }

        hb_photo=hb_photo.substring(0,hb_photo.length()-1);

        dto.setHb_photo(hb_photo);
        //db insert
        hireMapper.insertHireBoard(dto);

        return "redirect:list";
    }

    @GetMapping("/hireboarddetail")
    public String detail(int hb_idx, int currentPage, Model model){

        hireService.updateReadCount(hb_idx);
        HireBoardDto dto = hireService.getData(hb_idx);

        model.addAttribute("dto", dto);
        model.addAttribute("currentPage",currentPage);


        //Controller 디테일 페이지 보내는 부분.
        //사진 여러장 분할 처리.
        List<String> list = new ArrayList<>();
        StringTokenizer st = new StringTokenizer(dto.getHb_photo(),",");
        while (st.hasMoreElements()) {
            list.add(st.nextToken());
        }

        model.addAttribute("list",list);


        return "/main/hire/hireboarddetail";
    }

    @GetMapping("/hireboarddelete")
    public String deleteHireBoard(int hb_idx){

        String hb_photo = hireService.getData(hb_idx).getHb_photo();
        storageService.deleteFile(bucketName,"hire",hb_photo);

        hireService.deleteHireBoard(hb_idx);

        return "redirect:list";
    }


    @GetMapping("/hireupdateform")
    public String updateHireBoardform(@RequestParam(defaultValue = "1") int currentPage,
                                      @RequestParam(defaultValue = "0") int hb_idx, Model model)
    {
        HireBoardDto dto=hireService.getData(hb_idx);

        model.addAttribute("dto", dto);
        model.addAttribute("currentPage", currentPage);

        return "/main/hire/hireupdateform";
    }

    @PostMapping("/hireupdate")
    public String updateHireBoard(HireBoardDto dto,MultipartFile upload,int currentPage)
    {
        String filename="";
        //사진선택을 한경우에는 기존 사진을 버켓에서 지우고 다시 업로드를 한다
        if(!upload.getOriginalFilename().equals("")) {
            //기존 파일명 알아내기
            filename=hireService.getData(dto.getHb_idx()).getHb_photo();
            //버켓에서 삭제
            storageService.deleteFile(bucketName, "hire", filename);

            //다시 업로드후 업로드한 파일명 얻기
            filename=storageService.uploadFile(bucketName, "hire", upload);
            dto.setHb_photo(filename);
        }

        dto.setHb_photo(filename);
        //수정
        hireService.updateHireBoard(dto);


        //수정후 내용보기로 이동한다
        return "redirect:./hireboarddetail?hb_idx="+dto.getHb_idx()+"&currentPage="+currentPage;
    }

}
