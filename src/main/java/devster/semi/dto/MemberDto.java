package devster.semi.dto;

import lombok.Data;
import org.apache.ibatis.type.Alias;

import java.sql.Timestamp;

@Data
@Alias("MemberDto")
public class MemberDto {
    private int m_idx;
    private String m_email;
    private String m_pass;
    private int m_state;
    private String m_tele;
    private String m_name;
    private String m_nickname;
    private String m_photo;
    private String m_filename;
    private int ai_idx;
    private String ai_name;
    private String salt;
    private int m_type;
    private Timestamp m_date;
    private String cm_reg;
}
