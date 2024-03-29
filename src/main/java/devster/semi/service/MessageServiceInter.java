package devster.semi.service;

import devster.semi.dto.MessageDto;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public interface MessageServiceInter {

    public ArrayList<MessageDto> getMessageList(MessageDto dto);

    public ArrayList<MessageDto> getRoomContentList(MessageDto dto);

    public void MessageSendInList(MessageDto dto);

    public Map<String,Object> getMessagesWithOtherUser(MessageDto dto);

    public int getAllUnreadCount(String nickname);



   /* public String getOtherProfile(MessageDto dto);

    public int getUnreadCount(MessageDto dto);

    public void MessageReadChk(MessageDto dto);

    public int getMaxRoom(MessageDto dto);

    public int getExistChat(MessageDto dto);

    public String getSelectRoom(MessageDto dto);*/
}
