package devster.semi.mapper;


import devster.semi.dto.FreeBoardDto;
import devster.semi.dto.QboardDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface QboardMapper {
    public List<QboardDto> getAllPosts();
    public void insertPost(QboardDto dto);
    public void deletePost(int qb_idx);
    public void updatePost(QboardDto dto);
    public QboardDto getOnePost(int qb_idx);

    public String selectNickNameOfQb_idx(int qb_idx);
    public String selectPhotoOfQb_idx(int qb_idx);
    public int getTotalCount();
    public List<QboardDto> getPagingList(Map<String,Integer> map);
    public void updateReadCount(int qb_idx);
    public void increaseLikeCount(int qb_idx);
    public void increaseDislikeCount(int qb_idx);
    public List<FreeBoardDto> bestfreeboardPosts();
    public int countComment(int qb_idx);
    public List<QboardDto> bestQboardPosts();

    //좋아요 / 싫어요 관련 메서드들
    public void increaseGoodRp(int qb_idx);
    public void increaseBadRp(int qb_idx);
    public void decreaseGoodRp(int qb_idx);
    public void decreaseBadRp(int qb_idx);
    public int getGoodRpCount(int qb_idx);
    public int getBadRpCount(int qb_idx);
    public void addIncreasingGoodRpInfo(Map<String,Integer> map);
    public void deleteGoodRpInfo(Map<String,Integer> map);
    public void addIncreasingBadRpInfo(Map<String,Integer> map);
    public void deleteBadRpInfo(Map<String,Integer> map);
    public Integer getRpInfoBym_idx(Map<String,Integer> map);


    // 검색
    public List<QboardDto> searchlist(Map<String, Object> map);
    public int countsearch(Map<String, Object> map);


}
