local com = require("com");

logic = {};
-- 检测登录异常
function logic.check_login_exception()
	--检测是否密码错误
	local is_password_wrong = com.check_page_with_image_contains_text(124,582,611,644,"密码错");
	if is_password_wrong == true then
		sys.toast("账号或密码错误！");
		return "账号或密码错误！";
	end
	--优先检测是否被限制登录了
	local is_limited_login = com.check_page_with_image_contains_text(125,525,616,570,"因批量或者使用非法");
	if is_limited_login == true then
		sys.toast("检测到账号已被限制登录！");
		return "检测到账号已被限制登录！";
	end
	--是否投诉被限制登录了
	local is_complaint_result = com.check_page_with_image_contains_text(118,484,625,738,"骚扰");
	if is_complaint_result ==  true then
		sys.toast("检测到账号已被投诉封号！");
		return "检测到账号已被投诉封号！";
	end
	local is_third_part_login = com.check_page_with_image_contains_text(122,465,614,760,"第三");
	if is_third_part_login == true then
		sys.toast("检测到账号第三方登录被封号！");
		return "检测到账号第三方登录被封号！";
	end
	return "";
end
-- 自动62登录
function logic.auto_login(_tel,_pwd,_wx62_data)
	com.write_wx62_data(_wx62_data);
	sys.msleep(5000);
	--点击登录按钮
	com.random_tap_in_area(50,1203,342,1284);
	sys.msleep(1000);
	--切换微信登录
	com.random_tap_in_area(40,660,405,693);
	sys.msleep(1000);
	--点击账号输入框
	com.random_tap_in_area(228,448,517,479);
	sys.msleep(1000);
	--输入账号
	app.input_text(_tel:trim());
	--点击密码输入框	
	com.random_tap_in_area(215,466,568,526);
	sys.msleep(1000)
	--输入密码
	app.input_text(_pwd:trim());
	sys.msleep(2000);
	--点击登录按钮
	com.random_tap_in_area(77,779,819,848);
	--等待返回被限制登录或者让滑块加载完成
	sys.msleep(8000);
	
	--[[--检测是否密码错误
	local is_password_wrong = com.check_page_with_image_contains_text(124,582,611,644,"密码错");
	if is_password_wrong == true then
		sys.toast("账号或密码错误！");
		return "账号或密码错误！";
	end
	--优先检测是否被限制登录了
	local is_limited_login = com.check_page_with_image_contains_text(125,525,616,570,"因批量或者使用非法");
	if is_limited_login == true then
		sys.toast("检测到账号已被限制登录！");
		return "检测到账号已被限制登录！";
	end
	--是否投诉被限制登录了
	local is_complaint_result = com.check_page_with_image_contains_text(118,484,625,738,"骚扰");
	if is_complaint_result ==  true then
		sys.toast("检测到账号已被投诉封号！");
		return "检测到账号已被投诉封号！";
	end
	local is_third_part_login = com.check_page_with_image_contains_text(122,465,614,760,"第三");
	if is_third_part_login == true then
		sys.toast("检测到账号第三方登录被封号！");
		return "检测到账号第三方登录被封号！";
	end]]--
	local login_exception = logic.check_login_exception();
	if login_exception ~= "" then
		return login_exception;
	end
	sys.toast("账号状态正常，继续进行登录！");
	--检测是否到滑块验证了
	local is_security_notice = com.check_page_with_image_text(26,162,460,214,"拖动下方滑块完成拼图");
	if is_security_notice == true then
		while true do
			local res = com.get_dest_slide_location(377,255,715,645);
			if res[1] > 402 and res[2] ~= -1 then
				touch.tap(res[1],res[2]);
				touch.on(158, 700):move(res[1]-40,700):off();
				sys.msleep(10000);
				local is_security_notice_pass = com.check_page_with_image_text(26,162,460,214,"拖动下方滑块完成拼图");
				if is_security_notice_pass == false then
					break;
				end
			else
				sys.toast("滑块检测失败，刷新后重新检测！");
				touch.tap(688,791);
			end
			sys.msleep(3000);
		end
		sys.msleep(3000);
		--处理完滑块验证继续登录
		--点击登录
		touch.tap(356,866);
		--滑块过掉之后检测登录异常
		sys.msleep(8000);
		login_exception = logic.check_login_exception();
		if login_exception ~= "" then
			return login_exception;
		end
	end
	
	sys.msleep(7000);
	-- 提示完成
	sys.toast("处理匹配手机通讯录！");
	if com.check_page_with_image_text(238,515,511,579,"匹配手机通讯录") == true then
		-- 点击否
		touch.tap(249,793);
	end
	-- 提示完成
	sys.toast("自动登录完成！");
	return "";
end
-- 更改头像
function logic.change_head_image(_head_imge_url)
	--清除相册所有照片
	clear.all_photos();
	sys.msleep(2000);
	--下载图片
	com.download_pic_from_internet(_head_imge_url);
	sys.msleep(1000);
	--切换到我页面
	com.tap_to_my();
	sys.msleep(1000);
	--切换到个人信息页面
	com.random_tap_in_area(10,161,741,322);
	sys.msleep(1000);
	--切换到个人头像页面
	com.random_tap_in_area(10,161,741,322);
	sys.msleep(1000);
	--点击右上角按钮
	com.tap_nav_right();
	sys.msleep(1000);
	--从相册选择
	local is_new_change_head_image = com.check_page_with_image_text(15,1024,686,1110,"查看上一张头像");
	if is_new_change_head_image == false then
		com.random_tap_in_area(15,1024,686,1110);
	else
		com.random_tap_in_area(15,924,686,1010);
	end
	sys.msleep(1000);
	--切换到相机胶卷内
	com.random_tap_in_area(15,135,686,226);
	sys.msleep(1000);
	--选择图片上传
	com.random_tap_in_area(12,141,177,307);
	sys.msleep(1000);
	--点击完成按钮
	com.random_tap_in_area(633,1246,708,1301);
	sys.msleep(1000);
	--点击返回按钮
	com.tap_back();
	sys.msleep(1000);
	--点击返回按钮
	com.tap_back();
	sys.msleep(1000);
	--切换到首页
	com.tap_to_main();
	sys.msleep(1000);
	--提示完成
	sys.toast("更改头像完成！");
	
end
-- 更换昵称
function logic.change_wx_nickanme(_nickname)
	--点击个人资料页面tab
	com.random_tap_in_area(606,1235,687,1331);
	sys.msleep(1000);
	--点击到个人信息页面
	com.random_tap_in_area(10,161,741,322);
	sys.msleep(1000);
	--点击到设置昵称页面
	com.random_tap_in_area(33,329,741,389);
	sys.msleep(1000);
	--删除掉原有的昵称
	app.input_text("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b")
	sys.msleep(1000);
	--输入新的昵称
	sys.input_text(_nickname,true);
	sys.msleep(8000);
	--返回
	com.tap_back();
	sys.msleep(1000);
	--切换到首页
	com.tap_to_main();
	sys.msleep(1000);
	--提示完成
	sys.toast("更改昵称完成！");
	
end
-- 添加好友
function logic.add_frd(_frd_tel)
	sys.toast("准备添加：" .. _frd_tel .. "为好友！");
	--点击显示菜单
	com.tap_nav_right();
	sys.msleep(1000);
	--点击添加好友
	com.random_tap_in_area(487,247,712,308);
	sys.msleep(1000);
	--点击输入框
	com.random_tap_in_area(115,167,657,240);
	sys.msleep(1000);
	--输入微信号
	sys.input_text(_frd_tel);
	sys.msleep(1000);
	--点击搜索
	com.random_tap_in_area(140,139,617,233);
	sys.msleep(3000);
	-- 检查是否已经是好友
	local is_frd_result = screen.is_colors({
		{162, 1038, 0xf8f8f8},
		{520, 1057, 0xf8f8f8},
		{639, 1063, 0xf8f8f8},
		{247, 1072, 0xf8f8f8},
	}, 100);
	if is_frd_result == true then
		--点击返回按钮
		com.tap_back();
		sys.msleep(1000);
		--点击取消按钮
		com.random_tap_in_area(701,78,699,80);
		sys.msleep(1000);
		--点击返回按钮
		com.tap_back();
		sys.msleep(1000);
		--切换到首页
		com.tap_to_main();
		sys.msleep(1000);
		return "重复添加好友！";
	end
	-- 检查是否添加失败
	local add_frd_fail_result = com.check_page_with_image_text(144,558,554,629,"查找失败");
	if add_frd_fail_result == true then
		sys.toast("查找失败!");
		sys.msleep(1000);
		--点击取消按钮
		com.random_tap_in_area(701,78,699,80);
		sys.msleep(1000);
		--点击返回按钮
		com.tap_back();
		sys.msleep(1000);
		--切换到首页
		com.tap_to_main();
		sys.msleep(1000);
		return "查找失败！";
	end
	local add_frd_not_exist_result = com.check_page_with_image_text(271,197,489,240,"该用户不存在");
	if add_frd_not_exist_result == true then
		sys.toast("好友不存在！");
		sys.msleep(1000);
		--点击取消按钮
		com.random_tap_in_area(701,78,699,80);
		sys.msleep(1000);
		--点击返回按钮
		com.tap_back();
		sys.msleep(1000);
		--切换到首页
		com.tap_to_main();
		sys.msleep(1000);
		return "好友不存在！";
	end
	-- 检查是否操作频繁
	local add_frd_frequent_result = com.check_page_with_image_contains_text(160,196,580,250,"频繁");
	if add_frd_frequent_result == true then
		sys.toast("操作频繁！");
		sys.msleep(1000);
		--点击取消按钮
		com.random_tap_in_area(701,78,699,80);
		sys.msleep(1000);
		--点击返回按钮
		com.tap_back();
		sys.msleep(1000);
		--切换到首页
		com.tap_to_main();
		sys.msleep(1000);
		return "操作频繁！";
	end
	-- 检查好友是否状态异常
	local add_frd_exp_result = com.check_page_with_image_contains_text(156,194,597,243,"状态异常");
	if add_frd_exp_result == true then
		sys.toast("好友状态异常！");
		sys.msleep(1000);
		--点击取消按钮
		com.random_tap_in_area(701,78,699,80);
		sys.msleep(1000);
		--点击返回按钮
		com.tap_back();
		sys.msleep(1000);
		--切换到首页
		com.tap_to_main();
		sys.msleep(1000);
		return "好友状态异常！";
	end
	local add_contact_x, add_contact_y = screen.find_color({
		{181, 867, 0x1aad19},
		{305, 865, 0x1aad19},
		{497, 859, 0x1aad19},
		{555, 899, 0x1aad19},
		{505, 907, 0x1aad19},
		{395, 918, 0x1aad19},
		{260, 921, 0x1aad19},
		{197, 923, 0x1aad19},
	}, 85, 0, 0, 0, 0);
	--点击添加到通讯录
	touch.tap(add_contact_x,add_contact_y);
	sys.msleep(2000);
	--判断是否为无需验证的
	local add_frd_result_text = com.get_page_text_with_image(56,901,693,972);
	local is_add_no_verify = false;
	if add_frd_result_text ~= nil and 
		(
		string.find(add_frd_result_text,"发消息") ~= nil 
		or string.find(add_frd_result_text,"去打个招呼") ~= nil 
		) then
		is_add_no_verify = true;
	end
	if is_add_no_verify == true then
		--点击返回
		com.tap_back();
		sys.msleep(2000);
		--点击取消
		com.tap_nav_right();
		sys.msleep(2000);
		--点击返回到首页
		com.tap_back();
		sys.msleep(2000);
		return "";
	end
	--点击发送按钮
	com.tap_nav_right();
	sys.msleep(2000);
	local is_too_frequent_alert = com.check_page_with_image_contains_text(188,624,550,667,"频繁");
	if is_too_frequent_alert == true then
		--点击确定按钮
		touch.tap(377,742);
		sys.msleep(2000);
		--点击返回到添加页面
		com.tap_back();
		sys.msleep(1000);
		--点击返回到搜索页面
		com.tap_back();
		sys.msleep(1000);
		--点击取消按钮
		com.random_tap_in_area(701,78,699,80);
		sys.msleep(1000);
		--点击返回按钮
		com.tap_back();
		sys.msleep(1000);
		--切换到首页
		com.tap_to_main();
		sys.msleep(1000);
		sys.toast("操作频繁！");
		return "操作频繁！";
	end
	--点击返回按钮
	com.tap_back();
	sys.msleep(2000);
	--点击取消按钮
	com.random_tap_in_area(701,78,699,80);
	sys.msleep(1000);
	--点击返回按钮
	com.tap_back();
	sys.msleep(1000);
	--切换到首页
	com.tap_to_main();
	sys.msleep(1000);
	--提示完成
	sys.toast("添加好友" .. _frd_tel .."完成！");
	sys.msleep(1000);
	return "";
end
--获取未回复的消息的点
function logic.get_unresponse_msg()
	local dest_red_point_positions = screen.find_color({
		find_all = true,
		{ 99, 147, 0xf43530},
		{132, 149, 0xf43530},
		{118, 134, 0xf43530},
		{116, 166, 0xf43530},
		{103, 159, 0xf43530},
		{127, 139, 0xf43530},
		{127, 159, 0xf43530},
		{107, 139, 0xf43530},
		{105, 135, 0xf98d8b},
		{102, 136, 0xffffff},
		{123, 133, 0xfcbfbe},
		{123, 132, 0xffffff},
		{131, 158, 0xf76360},
		{132, 158, 0xffffff},
		{123, 166, 0xfcbfbe},
		{123, 167, 0xffffff},
	}, 100, 0, 0, 0, 0);

	local dest_red_point_positions_len = #dest_red_point_positions;
	if dest_red_point_positions_len == 0 then
		sys.toast("当前没有可回复的好友！");
		sys.msleep(1000);
		return "";
	end
	return dest_red_point_positions;
end
-- 给新好友发消息
function logic.send_new_frd_msg(_url)
	--下载自动回复消息文件
	local wx_auto_response_file_path = "/var/mobile/Media/1ferver/wxtools/resp.txt";
	com.download_file_from_internet(_url,wx_auto_response_file_path);
	local send_new_frd_msg_res = com.get_send_new_frd_msg_data(wx_auto_response_file_path);
	local send_new_frd_msg_res_len = #(send_new_frd_msg_res);
	--准备开始查看是否有可以自动回复用户
	local dest_red_point_positions = logic.get_unresponse_msg();
	local dest_red_point_positions_len = #dest_red_point_positions;
	sys.msleep(2000);
	while dest_red_point_positions_len~= 0 do
		while true do 
			if dest_red_point_positions[1][1] < 135 and 
			dest_red_point_positions[1][2] < 1235 then
				sys.msleep(1000);
				--回复文字消息
				if send_new_frd_msg_res[1] == "1" or send_new_frd_msg_res[1] == "2" then
					--点击对话记录
					touch.tap(dest_red_point_positions[1][1]+30,dest_red_point_positions[1][2] + 30);
					sys.msleep(1000);
					--检测是否有对话框
					local is_chat_dialog = screen.is_colors({
						{ 38, 1284, 0x7f8389},
						{ 44, 1284, 0x7f8389},
						{ 54, 1283, 0x7f8389},
						{622, 1294, 0x7f8389},
						{702, 1284, 0x7f8389},
					}, 90);
					if is_chat_dialog == false then
						com.tap_back();
						sys.msleep(1000);
						break;
					end
					--点击输入框
					com.random_tap_in_area(100,1256,561,1307);
					sys.msleep(1000);
					--粘贴文字并回复
					sys.input_text(send_new_frd_msg_res[2],true);
					sys.msleep(2000);
					--点击取消键盘
					touch.tap(23,148);
				end
				--回复图片
				if send_new_frd_msg_res[1] == "2" then
					local send_new_frd_msg_res_len = #(send_new_frd_msg_res);
					for j=send_new_frd_msg_res_len,3,-1 do
						--清除相册所有照片
						clear.all_photos();
						sys.msleep(1000);
						sys.toast(send_new_frd_msg_res[j]  .. "|index=" .. j);
						--下载图片
						com.download_pic_from_internet(send_new_frd_msg_res[j]);
						sys.msleep(4000);
						--点击加号
						com.random_tap_in_area(679,1258,722,1300);
						sys.msleep(1000);
						--点击照片
						com.random_tap_in_area(68,927,164,1014);
						sys.msleep(1000);
						--判断需要不需要点击相机胶卷
						local is_camera_list = com.check_page_with_image_text(122,149,273,205,"相机胶卷");
						if is_camera_list == true then
							--选择相机胶卷
							com.random_tap_in_area(123,158,342,212);
							sys.msleep(1000);
						end
						--点选照片
						sys.toast("点击点选照片");
						touch.tap(158,164);
						sys.msleep(1000);
						--发送
						com.random_tap_in_area(611,1268,710,1310);
						sys.msleep(2000);
					end
				end
				--返回
				com.tap_back();
				break;
			end
		end
		sys.msleep(2000)
		dest_red_point_positions = logic.get_unresponse_msg();
		dest_red_point_positions_len = #dest_red_point_positions;
	end
	if dest_red_point_positions_len == 0 then
		sys.toast("当前没有可回复的好友！");
		sys.msleep(20000);
	end
	
	--[[
	--原有函数已废弃，因为微信回复一个之后位置会变无法确定原来的位置
	local dest_red_point_positions = screen.find_color({
		find_all = true,
		{ 99, 147, 0xf43530},
		{132, 149, 0xf43530},
		{118, 134, 0xf43530},
		{116, 166, 0xf43530},
		{103, 159, 0xf43530},
		{127, 139, 0xf43530},
		{127, 159, 0xf43530},
		{107, 139, 0xf43530},
		{105, 135, 0xf98d8b},
		{102, 136, 0xffffff},
		{123, 133, 0xfcbfbe},
		{123, 132, 0xffffff},
		{131, 158, 0xf76360},
		{132, 158, 0xffffff},
		{123, 166, 0xfcbfbe},
		{123, 167, 0xffffff},
	}, 100, 0, 0, 0, 0);

	local dest_red_point_positions_len = #dest_red_point_positions;
	if dest_red_point_positions_len == 0 then
		sys.toast("当前没有可回复的好友！");
		sys.msleep(1000);
		return "当前没有可回复的好友！";
	end
	local tmp_dest_red_point_positions = {};
	for i=dest_red_point_positions_len,1,-1 do
		table.insert(tmp_dest_red_point_positions,dest_red_point_positions[i]);
	end
	--sys.toast("当前检测到：" .. #tmp_dest_red_point_positions .. "个需要回复！");
	
	--dest_red_point_positions = tmp_dest_red_point_positions;
	for i=dest_red_point_positions_len,1,-1 do
		while true do
			--只处理左侧的点
			if dest_red_point_positions[i][1] < 135 and 
			dest_red_point_positions[i][2] < 1235 then
				sys.msleep(1000);
				--回复文字消息
				if send_new_frd_msg_res[1] == "1" or send_new_frd_msg_res[1] == "2" then
					--点击对话记录
					touch.tap(dest_red_point_positions[i][1]+30,dest_red_point_positions[i][2] + 30);
					sys.msleep(1000);
					--检测是否有对话框
					local is_chat_dialog = screen.is_colors({
						{ 38, 1284, 0x7f8389},
						{ 44, 1284, 0x7f8389},
						{ 54, 1283, 0x7f8389},
						{622, 1294, 0x7f8389},
						{702, 1284, 0x7f8389},
					}, 90);
					if is_chat_dialog == false then
						com.tap_back();
						sys.msleep(1000);
						break;
					end
					--点击输入框
					com.random_tap_in_area(100,1256,561,1307);
					sys.msleep(1000);
					--粘贴文字并回复
					sys.input_text(send_new_frd_msg_res[2],true);
					sys.msleep(2000);
					com.tap_back();
				end
				--回复图片
				if send_new_frd_msg_res[1] == "2" then
					local send_new_frd_msg_res_len = #(send_new_frd_msg_res);
					for j=send_new_frd_msg_res_len,3,-1 do
						--清除相册所有照片
						clear.all_photos();
						sys.msleep(1000);
						sys.toast(send_new_frd_msg_res[j]  .. "|index=" .. j);
						--下载图片
						com.download_pic_from_internet(send_new_frd_msg_res[j]);
						sys.msleep(4000);
						--点击对话记录
						touch.tap(dest_red_point_positions[i][1]+30,dest_red_point_positions[i][2] + 30);
						sys.msleep(1000);
						--点击加号
						com.random_tap_in_area(679,1258,722,1300);
						sys.msleep(1000);
						--点击照片
						com.random_tap_in_area(68,927,164,1014);
						sys.msleep(1000);
						--判断需要不需要点击相机胶卷
						local is_camera_list = com.check_page_with_image_text(122,149,273,205,"相机胶卷");
						if is_camera_list == true then
							--选择相机胶卷
							com.random_tap_in_area(123,158,342,212);
							sys.msleep(1000);
						end
						--点选照片
						sys.toast("点击点选照片");
						touch.tap(158,164);
						sys.msleep(1000);
						--发送
						com.random_tap_in_area(611,1268,710,1310);
						sys.msleep(2000);
						--返回
						com.tap_back();
					end
					break;
				end
				com.tap_back();
				sys.msleep(1000);
			end
		end
	end]]--
	
end
-- 发送朋友圈
function logic.send_timeline(_url)
	local wx_auto_timeline_file_path = "/var/mobile/Media/1ferver/wxtools/tl.txt";
	com.download_file_from_internet(_url,wx_auto_timeline_file_path);
	local send_timeline_res = com.get_send_timeline_data(wx_auto_timeline_file_path);
	local send_timeline_res_len = #(send_timeline_res);
	
	--发送纯文字朋友圈
	sys.msleep(3000);
	if send_timeline_res[1] == "1" then
		--切换到朋友圈
		com.random_tap_in_area(442,1252,497,1319);
		sys.msleep(1000);
		--点击朋友圈
		com.random_tap_in_area(23,168,517,234);
		sys.msleep(1000);
		--长按发文字
		com.long_tap_nav_rignt();
		sys.msleep(1000);
		local is_first = com.check_page_with_image_text(286,1207,467,1260,"我知道了");
		if is_first == true then
			com.random_tap_in_area(270,1207,467,1260);
			sys.msleep(1000);
		end
		--删除原有文字
		sys.input_text("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b",false);
		--粘贴文字
		sys.input_text(send_timeline_res[2],false);
		sys.msleep(1000);
		--发送
		com.tap_nav_right();
		sys.msleep(1000);
		--返回
		com.tap_back();
		sys.msleep(1000);
		--切换到主页面
		com.tap_to_main();
	end
	--发图文朋友圈
	if send_timeline_res[1] == "2" then
		sys.toast("朋友圈图片下载中...");
		--清除相册所有照片
		clear.all_photos();
		sys.msleep(1000);
		for i=send_timeline_res_len,3,-1 do
			--下载图片
			com.download_pic_from_internet(send_timeline_res[i]);
			sys.msleep(2000)
		end
		sys.toast("朋友圈图片下载完成！");
		sys.msleep(5000);
		--切换到朋友圈
		com.random_tap_in_area(442,1252,497,1319);
		sys.msleep(1000);
		--点击朋友圈
		com.random_tap_in_area(23,168,517,234);
		sys.msleep(1000);
		--点击拍照按钮
		com.tap_nav_right();
		sys.msleep(5000);
		local is_first = com.check_page_with_image_text(103,822,616,882,"知道了");
		--第一次发朋友圈
		if is_first == true then
			com.random_tap_in_area(103,822,616,882);
			sys.msleep(1000);
		end
		--点击从相册选择照片
		com.random_tap_in_area(214,1132,510,1197);
		sys.msleep(1000);
		--选择相机胶卷
		com.random_tap_in_area(122,153,406,225);
		sys.msleep(1000);
		-- 选择照片
		local x_start = 158;
		local y_start = 164;
		for i=send_timeline_res_len,3,-1 do
			-- 行号
			local row_num = math.ceil((i - 2)/4);
			local column_num = math.fmod(i-2,4);
			if column_num == 0 then
				column_num = 4;
			end

			y = y_start + (row_num-1)*(178 + 8);
			x = x_start + (column_num-1)*(178 + 8);
			
			touch.tap(x,y);
			sys.msleep(1000);
		end
		-- 点击完成
		com.random_tap_in_area(617,1270,702,1310);
		sys.msleep(3000);
		sys.toast("照片选择完成！");
		--点击输入文字
		com.random_tap_in_area(60,179,306,221);
		sys.msleep(1000);
		sys.toast("点击输入文字！");
		
		--删除原有文字
		sys.input_text("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b",false);
		--粘贴文字
		sys.input_text(send_timeline_res[2],false);
		sys.msleep(1000);
		--发送
		com.tap_nav_right();
		sys.msleep(2000);
		--返回
		com.tap_back();
		sys.msleep(1000);
		--切换到主页面
		com.tap_to_main();
		
	end
	
end
function logic.show_user_config_dialog()
	local config_dialog = dialog();
	config_dialog:title('微信助手自动化软件v0.1');
	config_dialog:add_label('注意：除62数据登录之外的其余操作必须建立在微信停留在第一次登录后主界面的基础之上。请勿用于非法用途！！');
	config_dialog:add_radio('请选择操作', {'62数据登录', '自动修改昵称', '自动修改头像','自动添加好友','自动给新好友发消息','自动发朋友圈'});
	local confirm_taped, config_arr = config_dialog:show();
	if(confirm_taped) then
		return config_arr['请选择操作'];
	else
		return "";
	end
end
function logic.show_config_dialog()
	local config_dialog = dialog();
	config_dialog:title('微信助手自动化脚本v0.1');
	config_dialog:add_input('62数据地址(txt):', '');
	config_dialog:add_label('示例:http://t.cn/62.txt,文本内容格式:177----pwd----62，一行一个数据');
	config_dialog:add_input('随机昵称地址(txt):', '');
	config_dialog:add_label('示例:http://t.cn/nick.txt,一行一个昵称');
	config_dialog:add_input('随机头像地址(txt):', '');
	config_dialog:add_label('示例:http://t.cn/pic.txt,头像文件名请勿使用中文，尽可能使用数字编号，一行一个头像连接');
	config_dialog:add_input('自动回复地址(txt):', '');
	config_dialog:add_label('示例:http://t.cn/resp.txt，具体内容设置格式：0-你好，好久不见！或者1-你好，帮我集个赞吧🙏-http://t.cn/1.jpg');
	config_dialog:add_input('发圈地址(txt):', '');
	config_dialog:add_label('示例:http://t.cn/tl.txt,具体内容设置格式：0-你好，好久不见！或者1-你好，帮我集个赞吧🙏-http://t.cn/1.jpg');
	local confirm_taped, config_arr = config_dialog:show();
	if(confirm_taped) then
		if config_arr['62数据地址(txt):'] == "" 
			or config_arr['随机昵称地址(txt):'] == "" 
			or config_arr['随机头像地址(txt):'] == "" 
			or config_arr['自动回复地址(txt):'] == "" 
			or config_arr['发圈地址(txt):'] == "" then
			return {};
		else
			local wx62_data_link = config_arr['62数据地址(txt):'];
			local nickname_link = config_arr['随机昵称地址(txt):'];
			local head_image_link = config_arr['随机头像地址(txt):'];
			local auto_response_link = config_arr['自动回复地址(txt):'];
			local auto_timeline_link = config_arr['发圈地址(txt):'];
			return {
					wx62_data_link,
					nickname_link,
					head_image_link,
					auto_response_link,
					auto_timeline_link,
				};
		end
	else
		return {};
	end

end
--读取客户端配置文件有配置则返回
function logic.app_config_check()
	local app_undone_config = com.read_undone_app_config();
	return app_undone_config;
end
function logic.refresh_worker_progress_rate(one_app_config_data,process_rate)
	local one_app_config_data_arr = one_app_config_data:split("----");
	if(#one_app_config_data_arr ~= 5 
		and #one_app_config_data_arr ~= 6) then
		return false;
	end
	one_app_config_data_arr[5] = rate;
	
	local app_config_data_arr = com.read_app_config();
	local app_config_data_arr_len = #app_config_data_arr;
	local selected_config_data_index = 0;
	for i=app_config_data_arr_len,1,-1 do
		local tmp_one_app_config_data_arr = app_config_data_arr[i]:split("----");
		if((#tmp_one_app_config_data_arr == 5 or #tmp_one_app_config_data_arr == 6)
			and tmp_one_app_config_data_arr[1] == one_app_config_data_arr[1]
			and tmp_one_app_config_data_arr[2] == one_app_config_data_arr[2]
			and tmp_one_app_config_data_arr[3] == one_app_config_data_arr[3]
			and tmp_one_app_config_data_arr[4] == one_app_config_data_arr[4]) then
			selected_config_data_index = i;
		end
	end

	if selected_config_data_index == 0 then
		return false;
	end
	--更新进去
	local dest_one_app_config = app_config_data_arr[selected_config_data_index];
	local dest_one_app_config_arr = dest_one_app_config:split("----");
	dest_one_app_config_arr[5] = process_rate;
	app_config_data_arr[selected_config_data_index] = table.concat(dest_one_app_config_arr,"----");
	local app_config_data = table.concat(app_config_data_arr,"\r\n");

	com.write_app_config(app_config_data);
end
--账号登录记录
function logic.auto_login_log(_str)
	local file_path = "/var/mobile/Media/1ferver/wxtools/logs/wx_login_" .. os.date("%Y%m%d", os.time()) .. ".txt";
	com.write_file(file_path,os.date("%Y-%m-%d %H:%M:%S", os.time()) .. " " .. _str);
end
--自动记录可用账号
function logic.auto_log_avaliable_account(_str)
	local file_path = "/var/mobile/Media/1ferver/wxtools/logs/wx_login_ava_accounts_" .. os.date("%Y%m%d", os.time()) .. ".txt";
	com.write_file(file_path,_str);
end
function logic.del_frd(_url)
	local wx_del_frd_file_path = "/var/mobile/Media/1ferver/wxtools/del_frd.txt";
	com.download_file_from_internet(_url,wx_del_frd_file_path);
	local del_frd_data = com.read_del_frd_data(wx_del_frd_file_path);
	local limit_num = del_frd_data[1][1];
	local del_num = del_frd_data[1][2];
	local contact_num = logic.get_frd_num();
	if contact_num < tonumber(limit_num) then
		sys.toast("好友数量未达到" .. limit_num .. "个，不做处理！");
		sys.msleep(1000);
		return;
	end
	sys.msleep(1000);
	for i=del_num,1,-1 do
		logic.del_one_frd()
	end
end
function logic.del_one_frd_check_person_action(frd_x,frd_y)
	--点击好友
	touch.tap(frd_x + 50,frd_y-60);
	sys.msleep(2000);
	--点击右上角进入资料设置
	com.tap_nav_right();
	sys.msleep(2000);
	--查找删除按钮
	local del_frd_btn_x,del_frd_btn_y = screen.find_color({
		{299, 1021, 0xe64340},
		{327, 1022, 0xe64340},
		{344, 1019, 0xffffff},
		{355, 1019, 0xffffff},
		{366, 1018, 0xffffff},
		{377, 1018, 0xfadad9},
		{384, 1020, 0xffffff},
		{395, 1020, 0xf3a4a3},
		{406, 1023, 0xef8684},
		{431, 1023, 0xe64340},
	}, 85, 0, 0, 0, 0);
	if del_frd_btn_x == -1 
		or del_frd_btn_y == -1 then
		com.tap_back();
		sys.msleep(1000);
		return "此行为非个人账号！";
	end
	return "";
end
function logic.del_one_frd()
	--找到右侧小放大镜位置
	local right_search_x,right_search_y = screen.find_color({
		{722, 614, 0x555555},
		{722, 615, 0x555555},
		{725, 621, 0x565656},
		{733, 619, 0x595959},
		{735, 624, 0x6c6c6c},
		{735, 615, 0x858585},
		{734, 613, 0x555555},
		{730, 610, 0x555555},
	}, 85, 0, 0, 0, 0);
	sys.toast("right_search_x=" .. right_search_x .. ",right_search_y=" .. right_search_y);
	--先移动到最后一个好友上
	touch.on(right_search_x,right_search_y):move(728,1053):off();
	sys.msleep(2000);
	sys.toast("开始识别好友！")
	--获取到最后一个好友
	local frd_bottom_lines = screen.find_color({
		find_all = true,
		{ 0, 1007, 0xd9d9d9},
		{100, 1007, 0xd9d9d9},
		{291, 1007, 0xd9d9d9},
		{321, 1007, 0xd9d9d9},
		{564, 1007, 0xd9d9d9},
		{657, 1007, 0xd9d9d9},
		{700, 1007, 0xd9d9d9},
		{749, 1007, 0xd9d9d9},
	}, 85, 0, 0, 0, 0);
	
	local frd_alpha_bottom_lines = screen.find_color({
		find_all = true,
		{0, 700, 0xf0f0f6},
		{122, 700, 0xf0f0f6},
		{222, 700, 0xf0f0f6},
		{322, 700, 0xf0f0f6},
		{422, 700, 0xf0f0f6},
		{749, 700, 0xf0f0f6},
		{0, 699, 0xffffff},
		{122, 699, 0xffffff},
		{222, 699, 0xffffff},
		{322, 699, 0xffffff},
		{422, 699, 0xffffff},
		{749, 699, 0xffffff},
	}, 100, 0, 0, 0, 0);
	for i=#frd_alpha_bottom_lines,1,-1 do
		table.insert(frd_bottom_lines,frd_alpha_bottom_lines[i]);
	end
	--过滤掉底部的几个公共列表
	local tmp_frd_bottom_lines = {};
	for i=#frd_bottom_lines,1,-1 do
		if frd_bottom_lines[i][2] > 545 then
			table.insert(tmp_frd_bottom_lines,frd_bottom_lines[i]);
		end
	end
	frd_bottom_lines = tmp_frd_bottom_lines;
	local frd_bottom_lines_len = #frd_bottom_lines;
	local is_can_del_index = frd_bottom_lines_len;
	local check_frd_personal_res = logic.del_one_frd_check_person_action(frd_bottom_lines[is_can_del_index][1],
		frd_bottom_lines[is_can_del_index][2]);
	while check_frd_personal_res ~= "" 
		and is_can_del_index >= 1 do
		check_frd_personal_res = logic.del_one_frd_check_person_action(frd_bottom_lines[is_can_del_index][1],
		frd_bottom_lines[is_can_del_index][2]);
		if is_can_del_index == 0 then
			return "未查找到好友！";
		end
		is_can_del_index = is_can_del_index -1;
		sys.msleep(2000);
	end
	
	--查找删除按钮
	local del_frd_btn_x,del_frd_btn_y = screen.find_color({
		{299, 1021, 0xe64340},
		{327, 1022, 0xe64340},
		{344, 1019, 0xffffff},
		{355, 1019, 0xffffff},
		{366, 1018, 0xffffff},
		{377, 1018, 0xfadad9},
		{384, 1020, 0xffffff},
		{395, 1020, 0xf3a4a3},
		{406, 1023, 0xef8684},
		{431, 1023, 0xe64340},
	}, 85, 0, 0, 0, 0);
	--点击删除按钮
	touch.tap(del_frd_btn_x,del_frd_btn_y);
	sys.msleep(1000);
	--点击确认删除按钮
	touch.tap(350,1152);
	sys.msleep(1000);
	return "";
	
end
function logic.get_frd_num()
	--切换到通讯录
	touch.tap(280,1288);
	--开始滑动获取联系人
	while true do
		--获取联系人数量的坐标 
		local contact_num_x,contact_num_y = screen.find_color({
			{317, 858, 0xc7c7c7},
			{323, 858, 0x808080},
			{343, 858, 0x838383},
			{354, 859, 0x8e8e8e},
			{391, 861, 0x818181},
			{412, 863, 0x808080},
		}, 100, 0, 0, 0, 0);
		local contact_num_text = com.detect_image_text(0,contact_num_y-30,contact_num_x,contact_num_y + 30);
		
		contact_num_text = contact_num_text:ltrim();
		contact_num_text = contact_num_text:rtrim();
		sys.msleep(1000);
		if contact_num_text ~=  "" then
			local contact_num = tonumber(contact_num_text);
			if contact_num ~= nil then
				sys.toast("总计：" .. contact_num .. "位好友！");
				return contact_num;
			end
		else
			--找到右侧小放大镜位置
			local right_search_x,right_search_y = screen.find_color({
				{722, 614, 0x555555},
				{722, 615, 0x555555},
				{725, 621, 0x565656},
				{733, 619, 0x595959},
				{735, 624, 0x6c6c6c},
				{735, 615, 0x858585},
				{734, 613, 0x555555},
				{730, 610, 0x555555},
			}, 85, 0, 0, 0, 0);
			sys.toast("right_search_x=" .. right_search_x .. ",right_search_y=" .. right_search_y);
			touch.on(right_search_x,right_search_y):move(728,1053):off();
		end
		sys.msleep(2000);
	end
end
return logic;