com = {};
local wx_bid = "com.tencent.xin";
--关闭APP
function com.close_app()
	app.close(wx_bid);
end
--启动APP
function com.run_app()
	app.run(wx_bid);
end
--重启APP
function com.re_launch_wx()
	sys.msleep(3000);
	app.close(wx_bid);
	sys.msleep(1000);
	app.run(wx_bid);
	sys.msleep(1000);
end
function com.get_page_text_with_image(_left,_top,_right,_bottom)
	screen.keep();
	local text_got = screen.ocr_text(
		_left,
		_top,
		_right,
		_bottom,
		{
			lang = "chi_sim",
		});
	screen.unkeep();
	text_got = text_got:atrim();
	return text_got;
end
function com.check_page_with_image_contains_text(_left,_top,_right,_bottom,_target_text)
	screen.keep();
	local text_got = screen.ocr_text(
		_left,
		_top,
		_right,
		_bottom,
		{
			lang = "chi_sim",
		});
	screen.unkeep();
	text_got = text_got:atrim();
	if string.find(text_got,_target_text) ~= nil then
		return true;
	else
		return false;
	end
end
--检查图片的文字
function com.detect_image_text(_left,_top,_right,_bottom)
	screen.keep();
	local text_got = screen.ocr_text(
		_left,
		_top,
		_right,
		_bottom,
		{
			lang = "chi_sim",
			white_list = _targret_ext,
		});
	screen.unkeep();
	return text_got;
end
--依据图片检测当前页面
function com.check_page_with_image_text(_left,_top,_right,_bottom,_targret_ext)
	screen.keep();
	local text_got = screen.ocr_text(
		_left,
		_top,
		_right,
		_bottom,
		{
			lang = "chi_sim",
			white_list = _targret_ext,
		});
	screen.unkeep();
	if text_got:atrim() == _targret_ext then
		return true;
	else
		return false;
	end
end
--获取当前页面的标题-可能不太准确OCR的原因
function com.get_current_page_title()
	screen.keep();
	local text_title = screen.ocr_text(
		190,
		32,
		661,
		125,
		{
			lang = "chi_sim",
		});
	screen.unkeep();
	return text_title:trim();
end

------tap模块
function com.random_tap_in_area(_left,_top,_right,_bottom)
	local h = _right - _left;
	local v = _bottom - _top;
	local rand = math.random();
	--local x = _left + math.fmod(math.floor(rand*h),h);
	--local y = _top + math.fmod(math.floor(rand*v),v);
	local x = _left + h/2;
	local y = _top + v/2;
	touch.tap(x,y);
end

--返回
function com.tap_back()
	com.random_tap_in_area(11,81,89,103);
end
--切换到主页
function com.tap_to_main()
	com.random_tap_in_area(62,1244,138,1323);
end
--切换到我页面
function com.tap_to_my()
	com.random_tap_in_area(613,1239,692,1328);
end
--点击右上角图标按钮
function com.tap_nav_right()
	com.random_tap_in_area(672,64,727,102);
end
--长按右上角图标按钮
function com.long_tap_nav_rignt()
	touch.on(701,84):msleep(1000):off();
end
--62提取的数据文件和显示
function com.read_wx62_data_from_txt_file(_file_path)
	sys.toast("62数据提取文件为：" .. _file_path);
	if not file.exists(_file_path) then
		sys.alert("62数据提取文件不存在！脚本终止！");
		os.exit();
	end
	local wx62_data_res = {};
	local wx62_data = io.lines(_file_path);
	for one62_data in wx62_data do
		local one62_data_arr = one62_data:split("----");
		table.insert(wx62_data_res,one62_data_arr);
		sys.toast(one62_data);
	end
	io.close();
	return wx62_data_res;
end
function com.show_wx62_data(_wx62_data_res)
	for k,v in ipairs(_wx62_data_res) do
		local one_data = _wx62_data_res[k];
		for k_l,v_l in ipairs(one_data) do 
			sys.toast(one_data[1] .. "|" .. one_data[2] .. "|" .. one_data[3]);
			sys.msleep(1000);
		end
	end
end

--62数据的读取和写入
function com.read_wx62_data()
	local wx_app_data_path = app.data_path(wx_bid);
	local wx_data_file = wx_app_data_path .. "/Library/WechatPrivate/wx.dat";
	if not file.exists(wx_data_file) then
		sys.alert("62数据文件不存在！脚本终止！");
		os.exit();
	end
	local wx_data_file_obj = io.open(wx_data_file,"rb+");
	if not wx_data_file_obj then
		sys.alert("打开62数据文件失败！脚本终止！");
		os.exit();
	end
	
	local wx62_data = wx_data_file_obj:read('*a');
	wx_data_file_obj:close();
	local wx62_data_hex = wx62_data:to_hex();
	return wx62_data_hex;
end
function com.write_wx62_data(_wx62_data)
	app.quit(wx_bid);
	sys.msleep(1000);
	clear.keychain(wx_bid);
	local wx_app_data_path = app.data_path(wx_bid);
	os.execute("rm -r "..wx_app_data_path..'/Documents/*');
	os.execute("rm -r "..wx_app_data_path..'/tmp/*');
	os.execute("rm -r "..wx_app_data_path..'/Library/Caches/*');
	os.execute("rm -r "..wx_app_data_path..'/Library/WechatPrivate/');
	os.execute("rm -r "..wx_app_data_path..'/Library/WechatPrivate/host/');
	os.execute("rm -r "..wx_app_data_path..'/Library/Preferences/*');
	os.execute("mkdir "..wx_app_data_path..'/Library/WechatPrivate/');
	os.execute("chmod -R 777 "..wx_app_data_path..'/Library/WechatPrivate/');
	local wx62_data_file_obj = io.open(wx_app_data_path..'/Library/WechatPrivate/wx.dat', 'wb');
	if not wx62_data_file_obj then
		sys.alert("打开62数据文件失败！脚本终止！");
		os.exit();
	end
	_wx62_data = "" .. _wx62_data;
	wx62_data_file_obj:write( _wx62_data:trim():from_hex());
	wx62_data_file_obj:close();
	sys.msleep(2000);
	app.run(wx_bid);
end
--从文件中随机中取一个头像
function com.read_rand_wx_head_image_url_from_txt_file(_file_path)
		sys.toast("微信头像提取文件为：" .. _file_path);
		if not file.exists(_file_path) then
			sys.alert("微信头像文件不存在！脚本终止！");
			os.exit();
		end
		local wx_head_image_url_res = {};
		local wx_head_image_url_data = io.lines(_file_path);
		for one_head_image_url in wx_head_image_url_data do
			table.insert(wx_head_image_url_res,one_head_image_url:trim());
		end
		io.close();
		local wx_head_image_url_res_len = #wx_head_image_url_res;
		local rand = math.random();
		local rand_index = math.fmod(math.floor(rand*(wx_head_image_url_res_len-1)),(wx_head_image_url_res_len-1))  + 1;
		sys.toast("随机选中头像为：" .. wx_head_image_url_res[rand_index]:trim());
		return wx_head_image_url_res[rand_index];
end
--从文件中随机后去一个昵称
function com.read_rand_wx_nickname_from_txt_file(_file_path)
		sys.toast("微信昵称提取文件为：" .. _file_path);
		if not file.exists(_file_path) then
			sys.alert("微信昵称文件不存在！脚本终止！");
			os.exit();
		end
		local wx_nickname_res = {};
		local wx_nickname_data = io.lines(_file_path);
		for one_nickname in wx_nickname_data do
			table.insert(wx_nickname_res,one_nickname:trim());
		end
		io.close();
		local wx_nickname_len = #wx_nickname_res;
		local rand = math.random();
		local rand_index = math.fmod(math.floor(rand*(wx_nickname_len-1)),(wx_nickname_len-1))  + 1;
		sys.toast("随机选中昵称为：" .. wx_nickname_res[rand_index]);
		return wx_nickname_res[rand_index];
end
--从文件中读取微信号
function com.read_wx_id_from_txt_file(_file_path)
		sys.toast("微信ID提取文件为：" .. _file_path);
		if not file.exists(_file_path) then
			sys.alert("微信ID文件不存在！脚本终止！");
			os.exit();
		end
		local wx_id_res = {};
		local wx_id_data = io.lines(_file_path);
		for one_id in wx_id_data do
			table.insert(wx_id_res,one_id:trim());
		end
		io.close();
		return wx_id_res;
end
--从网络上下载图片保存到本地相册
function com.download_pic_from_internet(_url)
	local resp_code, resp_header, resp_res = http.get(_url, 10)
	if (resp_code == 200) then
		local pic_download = image.load_data(resp_res);
		pic_download:save_to_album();
		sys.toast("图片：" .. _url .. "下载成功，已存到相册！");
	else
		sys.alert("图片：" .. _url .. "下载失败！");
	end
end
--从网络下载文件保存到本地
function com.download_file_from_internet(_url,_file_path)
	local resp_code, resp_header, resp_res = http.get(_url, 10)
	if (resp_code == 200) then
		local file_obj = io.open(_file_path,"wb");
		if not file_obj then
			sys.alert("打开文件：" .. _file_path .. "失败！");
			os.exit();
		end
		file_obj:write(resp_res);
		file_obj:close();
		sys.toast("文件：" .. _url .. "下载成功，已存到" .. _file_path .. "！");
		return true;
	else
		sys.alert("文件：" .. _url .. "下载失败！");
		return false;
	end
end
function com.get_send_new_frd_msg_data(_file_path)
	if not file.exists(_file_path) then
		sys.alert("新好友发送消息文件不存在！脚本终止！");
		os.exit();
	end
	local send_new_frd_msg_res = {};
	local send_new_frd_msg_data = io.lines(_file_path); 
	for one_send_new_frd_msg_data in send_new_frd_msg_data do
		local one_send_new_frd_msg_data_arr = one_send_new_frd_msg_data:split("----");
		local one_send_new_frd_msg_data_arr_len = #(one_send_new_frd_msg_data_arr);
		if one_send_new_frd_msg_data_arr_len >= 2 then
			table.insert(send_new_frd_msg_res,one_send_new_frd_msg_data_arr);
		end
	end
	io.close();
	local rand_index = math.random(#send_new_frd_msg_res);
	return send_new_frd_msg_res[rand_index];
end
function com.get_send_timeline_data(_file_path)
	if not file.exists(_file_path) then
		sys.alert("发朋友圈文件不存在！脚本终止！");
		os.exit();
	end
	local send_timeline_res = {};
	local send_timeline_data = io.lines(_file_path); 
	for one_send_timeline_data in send_timeline_data do
		local one_timeline_data_arr = one_send_timeline_data:split("----");
		local one_timeline_data_arr_len = #(one_timeline_data_arr);
		if one_timeline_data_arr_len >= 2 then
			table.insert(send_timeline_res,one_timeline_data_arr);
		end
		
	end
	io.close();
	local rand_index = math.random(#send_timeline_res);
	return send_timeline_res[rand_index];
end
function com.check_script_authed()
	local resp_code, resp_header, resp_res = http.get("http://ykt.bichonfrise.cn/wxtools/auth.php", 10)
	if (resp_code == 200) then
		local auth_resp_res_arr = resp_res:trim():split("|");
		if tonumber(auth_resp_res_arr[1]) > tonumber(auth_resp_res_arr[2]) then
			return false;
		end
		return true;
	else
		sys.alert("网络错误，请联网进行脚本授权！");
		return false;
	end
end
function com.check_faker_authed()
	local resp_code, resp_header, resp_res = http.get("http://ykt.bichonfrise.cn/wxtools/faker_auth.php", 10)
	if (resp_code == 200) then
		local auth_resp_res_arr = resp_res:trim():split("|");
		if tonumber(auth_resp_res_arr[1]) > tonumber(auth_resp_res_arr[2]) then
			return false;
		end
		return true;
	else
		sys.alert("网络错误，请联网进行脚本授权！");
		return false;
	end
end
function str_to_time(_str)
	--2018-09-09 00:00:00
	local _str_arr = _str:split(" ");
	local date = _str_arr[1];
	local time = _str_arr[2];
	local date_arr = date:split("-");
	local time_arr = time:split(":");
	--sys.alert(date_arr[1] .. "|" .. date_arr[2] .. "|" .. date_arr[3]);
	--sys.alert(time_arr[1] .. "|" .. time_arr[2] .. "|" .. time_arr[3]);
	return os.time({year=date_arr[1], month=date_arr[2], day=date_arr[3], hour=time_arr[1], min=time_arr[2], sec=time_arr[3]});
end
function com.write_app_config(app_config_data)
	local app_config_data_file_obj = io.open('/var/mobile/Media/1ferver/wxtools/task.txt', 'w');
	if not app_config_data_file_obj then
		sys.alert("APP配置文件不存在！脚本终止！");
		os.exit();
	end
	app_config_data = "" .. app_config_data;
	app_config_data_file_obj:write(app_config_data:trim());
	app_config_data_file_obj:close();
end
function com.read_app_config()
	local _file_path = "/var/mobile/Media/1ferver/wxtools/task.txt"
	if not file.exists(_file_path) then
		sys.alert("APP配置文件不存在！脚本终止！");
		os.exit();
	end
	local app_config_res = {};
	local app_config_data = io.lines(_file_path); 
	for one_app_config_data in app_config_data do
		if one_app_config_data ~= "" then	
			
			table.insert(app_config_res,one_app_config_data:rtrim());
		end
	end
	io.close();
	return app_config_res;
end
function com.read_undone_app_config()
	local _file_path = "/var/mobile/Media/1ferver/wxtools/task.txt"
	if not file.exists(_file_path) then
		sys.alert("APP配置文件不存在！脚本终止！");
		os.exit();
	end
	local app_config_res = {};
	local app_config_data = io.lines(_file_path); 
	for one_app_config_data in app_config_data do
		if one_app_config_data ~= "" then	
			local one_app_config_data_arr = one_app_config_data:split("----");
			if #one_app_config_data_arr == 5 or #one_app_config_data_arr == 6 then 
				-- 判断时间到了没完成的
				if one_app_config_data_arr[5]:trim() ~= "100%"  
				and str_to_time(one_app_config_data_arr[3]) <= os.time() then
					table.insert(app_config_res,one_app_config_data);
				end
			end
		end
	end
	io.close();
	
	--把倒序的正序过来
	local app_config_res_len = #app_config_res;
	local tmp_app_config_res = {};
	for i = app_config_res_len,1,-1 do
		table.insert(tmp_app_config_res,app_config_res[i]);
	end
	app_config_res = tmp_app_config_res;
	return app_config_res;
end
--匹配滑块
function com.get_dest_slide_location(l_t_x,l_t_y,r_b_x,r_b_y)
	local x,y = screen.find_color({
				max_miss=5,
				{620, 522, 0xfffbf7},
				{620, 534, 0xfffefb},
				{620, 548, 0xfffefb},
				{620, 563, 0xfffefb},
				{620, 584, 0xfffcf8},
				{616, 610, 0xfffcfa},
				{597, 610, 0xfffef8},
				{582, 610, 0xfffdfa},
				{565, 611, 0x49423a},
				{546, 610, 0xfffdfa},
				{532, 603, 0xfcfbf9},
				{532, 584, 0xfffefb},
				{547, 568, 0xfffffb},
				{532, 544, 0xf9f8f6},
				{532, 526, 0xfaf6f5},
				{540, 522, 0xfffefa},
				{549, 522, 0xfffefa},
				{577, 508, 0xfff8f6},
				{601, 522, 0xfffef8},
				{614, 522, 0xfffdfb},
		}, 90, l_t_x, l_t_y, r_b_x, r_b_y);
	local res = {};
	table.insert(res,x);
	table.insert(res,y);
	return res;
end
function com.write_file(_file_path,_str)
	if not file.exists(_file_path) then
		os.execute("touch " .. _file_path);
	end
	local file_obj = io.open(_file_path, 'a');
	if not file_obj then
		sys.toast(_file_path .. " 文件不存在，无法写入！");
		return;
	end
	file_obj:seek("end",-1);
	_str = _str:ltrim();
	file_obj:write(_str:rtrim() .. "\r\n");
	file_obj:close();
	sys.toast("文件:" .. _file_path .." 写入数据:" .. _str .. "成功！");
end
function com.read_del_frd_data(_file_path)
	if not file.exists(_file_path) then
		sys.alert("删除好友配置文件不存在！脚本终止！");
		os.exit();
	end
	local del_frd_res = {};
	local del_frd_data = io.lines(_file_path); 
	for one_del_frd_data in del_frd_data do
		if one_del_frd_data ~= "" then	
			local one_del_frd_data_arr = one_del_frd_data:split("----");
			if #one_del_frd_data_arr == 2 then 
				table.insert(del_frd_res,one_del_frd_data_arr);
			end
		end
	end
	io.close();
	return del_frd_res;
	
end
--切换网络
function com.switch_network_ip()
	device.turn_on_airplane();
	sys.msleep(5000);
	device.turn_off_airplane();
	sys.msleep(5000);
end
--获取随机微信ID或者密码
function com.get_random_str(_str,random_len)
	if _str ~= "" then 
		return _str;
	end
	local  char_set = {"1","2","3","4","5","6","7","8","9","0",
						--[["a","b","c","d","e","f","g","h","i","j",
						"k","l","m","n","o","p","q","r","s","t",
						"u","v","w","x","y","z",]]--
						"A","B","C","D","E","F","G","H","I","J",
						"K","L","M","N","O","P","Q","R","S","T",
						"U","V","W","X","Y","Z"
						};
	local char_set_len = #char_set;
	local word_set = {"blear","filmy","foggy","valid","crane","smell","spell","small","large","brick",
						"crack","bread","toast","skill","smash","trade","refer","angle","spite","apple",
						"often","usual","moody","cloud","windy","aloud","scare","scard","movie","radio",
						"laser","print","scarf","bloom","gloom","great","greet","think","broom","scrip",
						"pluge","smart","sweet","sweat","grant","twist","viewy","scrum","nicho","annie",
		};
	local word_set_len = #word_set;
	local rand_word_index =  math.fmod(tonumber(math.floor(math.random()*word_set_len)),word_set_len) + 1;
	-- 前缀 word_set[rand_word_index]
	local rand_char_suffix = "";
	for i=random_len,1,-1 do
		local rand_char_suffix_index = math.fmod(tonumber(math.floor(math.random()*char_set_len)),char_set_len) + 1;
		rand_char_suffix = rand_char_suffix .. char_set[rand_char_suffix_index];
	end
	return word_set[rand_word_index] .. "_" .. rand_char_suffix;
end
return com;