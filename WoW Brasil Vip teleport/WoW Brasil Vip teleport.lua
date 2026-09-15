function PlayerLink(self, button, down)
   if ( IsModifiedClick("CHATLINK") ) then
    if IsModifierKeyDown() then
     zone=WorldMapFrameAreaLabel:GetText() 
     if zone then 
      zone=string.gsub(zone, " |cff.+$", "") 
      zone=string.format(string.gsub(string.format(string.gsub(zone, "'", "")), "%s", "")) 
      SendChatMessage(".tele "..zone, "GUILD") 
      print(".tele "..zone) 
     end
 
    end
   end
end
WorldMapButton:HookScript("OnClick", PlayerLink)


local origScript = WorldMapButton_OnClick
WorldMapButton_OnClick = function(self, ...) 
    if IsModifierKeyDown() then
     zone=WorldMapFrameAreaLabel:GetText() 
     if zone then 
      zone=string.gsub(zone, " |cff.+$", "") 
      zone=string.format(string.gsub(string.format(string.gsub(zone, "'", "")), "%s", "")) 
      SendChatMessage(".tele "..zone, "GUILD") 
      print(".tele "..zone) 
     end
 
    end
end


print('WoW Brasil VIP teleport - Basta clicar no mapa segurando shift em algum lugar que mostre nome do local ao passar o mouse em cima')


