package devster.semi.mapper;

import devster.semi.dto.FreeCommentDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface FreeCommentMapper {
    public int getTotalComment(int fb_idx);
    public int getMaxNum();
    public void updateStep(Map<String, Integer> map);
    public FreeCommentDto getFreeComment(int fbc_idx);
    public List<FreeCommentDto> getAllCommentList(int fb_idx);
    public void insertFreeComment(FreeCommentDto dto);
    public void insertFreeReply(FreeCommentDto dto);
    public List<FreeCommentDto> getReplyOfRef(int fbc_idx);
    public void updateFreeComment(FreeCommentDto dto);
    public void deleteFreeComment(int fbc_idx);
    public int countReply(int fbc_idx);

    public String selectNickNameOfFbc_idx(int fbc_idx);
    public String selectPhotoOfFbc_idx(int fbc_idx);

}
