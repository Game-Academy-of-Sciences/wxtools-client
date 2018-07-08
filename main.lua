local logic = require('logic');
local nicFaker = require('nicFaker');
local guard_thread_id = nil;
local worker_thread_id = nil;
local one_app_config_data = nil;
local one_wx_62_data = nil;
--faker模块使用变量
local nicFaker = require('nicFaker');
local backup_file_path = "/var/mobile/Media/1ferver/wxtools/wx.backups/";

--处理除了登录之外的所有业务逻辑
function disptach_business_work(one_app_config_data_arr, wx62_data_index,wx62_data_num)
	local config_name = one_app_config_data_arr[2];
	sys.toast("正在处理：" .. config_name);
	-- 更改昵称
	if config_name == "修改昵称" then
		--下载微信昵称
		local wx_nickname_file_url = one_app_config_data_arr[4];
		local wx_nickname_file_path = "/var/mobile/Media/1ferver/wxtools/nickname.txt";
		com.download_file_from_internet(wx_nickname_file_url,wx_nickname_file_path);
		sys.msleep(3000);
		--自动修改昵称
		--com.re_launch_wx()
		local wx_rand_nickname = com.read_rand_wx_nickname_from_txt_file(wx_nickname_file_path);
		logic.change_wx_nickanme(wx_rand_nickname);
		sys.msleep(2000);
		sys.toast("配置名称：" .. config_name .. "  配置链接：" .. one_app_config_data_arr[4] .. " 配置启动时间：" .. one_app_config_data_arr[3]);
	end
	if config_name == "修改头像" then
		--下载微信头像文件
		local wx_head_image_url = one_app_config_data_arr[4];
		local wx_head_image_file_path = "/var/mobile/Media/1ferver/wxtools/pics.txt";
		com.download_file_from_internet(wx_head_image_url,wx_head_image_file_path);
		sys.msleep(2000);
		--自动修改头像
		--com.re_launch_wx();
		local head_image_url = com.read_rand_wx_head_image_url_from_txt_file(wx_head_image_file_path);
		logic.change_head_image(head_image_url);
		sys.toast("配置名称：" .. config_name .. "  配置链接：" .. one_app_config_data_arr[4] .. " 配置启动时间：" .. one_app_config_data_arr[3]);
	end
	if config_name == "添加好友" then
		if #one_app_config_data_arr ~= 6 then
			sys.toast("添加好友任务配置错误！");
			return;
		end
		--下载微信好友
		local frd_wxid_file_url = one_app_config_data_arr[4];
		local frd_wxid_file_path = "/var/mobile/Media/1ferver/wxtools/wxids.txt";
		com.download_file_from_internet(frd_wxid_file_url,frd_wxid_file_path);
		sys.msleep(3000);
		--自动添加微信好友 正序
		local wx_ids_res = com.read_wx_id_from_txt_file(frd_wxid_file_path);
		local wx_ids_res_len = #wx_ids_res;
		--开始分割微信id单行
		sys.toast("开始分割微信ID!");
		--读取62数据配置文件，查看有多少个62数据
		local wx_id_file_num = tonumber(math.ceil(wx_ids_res_len/tonumber(one_app_config_data_arr[6])));
		if wx_id_file_num < wx62_data_num then
			sys.toast("微信ID不够分配！");
			sys.msleep(2000);
			return "微信ID不够分配！";
		end
		--分割微信ID
		local i=1;
		local per_wx_add_frd_num = tonumber(one_app_config_data_arr[6]);
		--删除原有文件
		os.execute("rm -rf /var/mobile/Media/1ferver/wxtools/wxids_*.txt");
		while i<= wx_id_file_num do
			local j = 0;
			local tmp_index = (i-1)*per_wx_add_frd_num + j + 1;
			while j < per_wx_add_frd_num and tmp_index <= #wx_ids_res do
				local per_wx_add_frd_file_name = "/var/mobile/Media/1ferver/wxtools/wxids_" .. i .. ".txt";
				com.write_file(per_wx_add_frd_file_name,wx_ids_res[tmp_index]);
				j = j+1;
				tmp_index = (i-1)*per_wx_add_frd_num + j + 1;
			end
			i = i+ 1;
		end
		
		local one_frd_wxid_file_path = "/var/mobile/Media/1ferver/wxtools/wxids_" .. wx62_data_index .. ".txt";

		local wx_id_res = com.read_wx_id_from_txt_file(one_frd_wxid_file_path);
		local wx_id_res_len = #wx_id_res;
		--循环添加好友
		local add_frd_success_log_file_name = "/var/mobile/Media/1ferver/wxtools/add_frd_succ_log.txt";
		local add_frd_success_content = nil;
		local add_frd_success_num = 0;
		for i=wx_id_res_len,1,-1 do
			local add_frd_res = logic.add_frd(wx_id_res[i]);
			--已发送添加消息成功写日志
			if add_frd_res == "" then
				add_frd_success_num = add_frd_success_num + 1;
			end
			if add_frd_res == "操作频繁！" then
				break;
			end
		end
		local add_frd_success_content = one_wx_62_data .. "----" .. add_frd_success_num;
		com.write_file(add_frd_success_log_file_name,add_frd_success_content);
		sys.toast("配置名称：" .. config_name .. "  配置链接：" .. one_app_config_data_arr[4] .. " 配置启动时间：" .. one_app_config_data_arr[3]);
	end
	if config_name == "新好友回复" then
		--下载自动回复消息文件并自动回复
		local wx_auto_response_url = one_app_config_data_arr[4];
		logic.send_new_frd_msg(wx_auto_response_url);
		sys.toast("配置名称：" .. config_name .. "  配置链接：" .. one_app_config_data_arr[4] .. " 配置启动时间：" .. one_app_config_data_arr[3]);
	end
	if config_name == "发朋友圈" then
		--下载自动发朋友圈文件
		local wx_auto_timeline_url = one_app_config_data_arr[4];
		logic.send_timeline(wx_auto_timeline_url);
		sys.toast("配置名称：" .. config_name .. "  配置链接：" .. one_app_config_data_arr[4] .. " 配置启动时间：" .. one_app_config_data_arr[3]);
	end
	if config_name == "删除好友" then
		local wx_del_frd_url = one_app_config_data_arr[4];
		local del_frd_res = logic.del_frd(wx_del_frd_url);
		sys.toast("配置名称：" .. config_name .. "  配置链接：" .. one_app_config_data_arr[4] .. " 配置启动时间：" .. one_app_config_data_arr[3]);
	end
	if config_name == "修改微信ID" then
	end
end
--worker线程
function worker_thread()
	local one_app_config_data_arr = one_app_config_data:split("----");
	if #one_app_config_data_arr ~= 5 and #one_app_config_data_arr ~= 6 then
		return false;
	end
	--读取配置文件自动登录
	local wx62_data_file_path = "/var/mobile/Media/1ferver/wxtools/62data.txt";
	local wx62_data_res = com.read_wx62_data_from_txt_file(wx62_data_file_path);
	sys.msleep(1000);
	--获取到每一个微信账号，进行自动登录操作
	local wx62_data_res_len = #wx62_data_res;
	for i=wx62_data_res_len, 1, -1 do 
		--lua里面没有continue 不得不用这么恶心的实现
		while true do 
			if #(wx62_data_res[i]) ~= 3 then
				logic.auto_login_log(table.concat(wx62_data_res[i],"----") .. "----此条62数据格式配置错误，请自行检查配置文件！" );
				sys.toast("此条62数据格式配置错误，请自行检查配置文件！");
				break;
			end
			one_wx_62_data = table.concat(wx62_data_res[i],"----");
			--faker伪装判断模块
			local is_account_backup_record_exist = nicFaker.check_account_backup_record(wx62_data_res[i][1], backup_file_path);
			if is_account_backup_record_exist == true then
				nicFaker.set_fake_app();
				sys.toast("一键新机成功，开始还原账号信息！");
				sys.msleep(5000);
				
				nicFaker.restore_app(wx62_data_res[i][1], backup_file_path);
				sys.toast("账号:" .. wx62_data_res[i][1] .. "备份文件存在,还原成功！");
				sys.msleep(2000);
				--打开APP
				com.run_app();
				sys.msleep(10000);
				--处理业务
				disptach_business_work(one_app_config_data_arr,i,wx62_data_res_len);
				sys.msleep(2000);
				--业务处理完成开始备份
				sys.toast("业务处理完成，开始备份账号信息！");
				local account_backup_file_path = nicFaker.backup_app(true,false,backup_file_path .. wx62_data_res[i][1]);
				sys.toast("账号：" .. account_backup_file_path .. "备份完成！");
			else
				nicFaker.set_fake_app_no_clear();
				sys.toast("一键新机成功，开始登录账号！");
				sys.msleep(5000);
				--自动登录
				local login_res = logic.auto_login(wx62_data_res[i][1],
					wx62_data_res[i][2],
					wx62_data_res[i][3]);
				sys.msleep(1000);
				if login_res == "" then
					--处理任务
					logic.auto_login_log(table.concat(wx62_data_res[i],"----") .. "----账号登录成功！" );
					logic.auto_log_avaliable_account(table.concat(wx62_data_res[i],"----"));
					disptach_business_work(one_app_config_data_arr,i,wx62_data_res_len);
					sys.msleep(2000);
					--业务处理完成开始备份
					sys.toast("业务处理完成，开始备份账号信息！");
					local account_backup_file_path = nicFaker.backup_app(true,false,backup_file_path .. wx62_data_res[i][1]);
					sys.toast("账号：" .. account_backup_file_path .. "备份完成！");
				else
					logic.auto_login_log(table.concat(wx62_data_res[i],"----") .. "----" .. login_res );
					com.switch_network_ip();
				end
			end
			break;
			
			
		end
		--更新任务进度
		local process_rate = math.floor(tonumber((wx62_data_res_len-i + 1)/(wx62_data_res_len)*100)) .. "%";
		sys.toast("当前进度：" .. process_rate);
		logic.refresh_worker_progress_rate(one_app_config_data,process_rate);
		if math.fmod(i,20) == 0 then
			com.switch_network_ip();
		end
	end
	--local wx62_data_index = 4;--12-8,7,6
end
--检查授权
function check_auth()
	-- 检查授权
	local is_authed = com.check_script_authed();
	if is_authed ~= true then
		sys.alert("脚本未授权，无法正常使用，准备退出！");
		os.exit();
	end
	-- 检查faker模块是否授权
	local is_faker_authed = com.check_faker_authed();
	if is_faker_authed ~= true then
		sys.alert("faker模块未授权，无法正常使用，准备退出！");
		os.exit();
	end
end
--app初始化
function app_init()
	--先放在这里，以后再去掉
	check_auth();
	--创建app配置目录 wxtools
	if not file.exists("/var/mobile/Media/1ferver/wxtools") then
		os.execute("mkdir -p /var/mobile/Media/1ferver/wxtools");
	end
	--创建app日志目录
	if not file.exists("/var/mobile/Media/1ferver/wxtools/logs") then
		os.execute("mkdir -p /var/mobile/Media/1ferver/wxtools/logs");
	end
	--创建任务文件
	if not file.exists("/var/mobile/Media/1ferver/wxtools/task.txt") then
		os.execute("touch /var/mobile/Media/1ferver/wxtools/task.txt");
	end
	--创建62数据文件
	if not file.exists("/var/mobile/Media/1ferver/wxtools/62data.txt") then
		os.execute("touch /var/mobile/Media/1ferver/wxtools/62data.txt");
	end
	--清理备份文件
	if file.exists(backup_file_path) then
		os.execute("rm -rf " .. backup_file_path .. "*");
	end
	
	
	--加载faker模块
	local url = "http://ykt.bichonfrise.cn/wxtools/XXTFaker-0.27.xxt";
	local is_instaled = nicFaker.install_faker_module(url);
	if is_instaled == false then
		sys.toast("安装faker模块失败！");
	end
	
end
--启动守护线程
function run_guard_thread()
	--显示触摸效果
	touch.show_pose(true);
	guard_thread_id = thread.dispatch(
			function()
				while true do 
					--读取配置文件
					sys.toast("守护线程运行中！");
					local res = logic.app_config_check();
					local res_len = #res;
					check_auth();
					--如果有任务则执行
					if res_len ~= 0 then
						for i=res_len,1,-1 do
							one_app_config_data = res[i];
							sys.toast("发现等待执行任务！");
							worker_thread_id = thread.dispatch(worker_thread);
							thread.wait(worker_thread_id);
							thread.kill(worker_thread_id);
							worker_thread_id = nil;
						end 
					else
						sys.toast("未发现可执行的任务！");
						sys.msleep(1000)
						--清除所有备份
						nicFaker.clear_all_backup_record(backup_file_path);
						
					end
					sys.msleep(5000);
				end
			end
		
		)
end
--自动登录
function main()
	app_init();
	run_guard_thread();
	
	
	
	--从界面读取配置文件
	--local dialog_conf = logic.show_config_dialog();
	--if #(dialog_conf) == 0 then
	--	sys.alert("您尚未配置完整或自行退出，退出脚本");
	--end
	--sys.alert("wx62_data_link=" .. dialog_conf[1] ..
	--	"nickname_link=" .. dialog_conf[2] ..
	--	"head_image_link=" .. dialog_conf[3] ..
	--	"auto_response_link=" .. dialog_conf[4] ..
	--	"auto_timeline_link=" .. dialog_conf[5]);
	
	--给用户弹出界面选择操作
	--[[local dialog_conf = logic.show_user_config_dialog();
	if dialog_conf == "62数据登录" then
		--下载62数据
		local wx62_data_file_url = "http://ykt.bichonfrise.cn/wxtools/20.txt";
		local wx62_data_file_path = "/private/var/wxtools/10.txt";
		com.download_file_from_internet(wx62_data_file_url,wx62_data_file_path);
		sys.msleep(3000);
		--微信自动登录
		local wx62_data_res = com.read_wx62_data_from_txt_file(wx62_data_file_path);
		sys.msleep(1000);
		local wx62_data_res_len = #wx62_data_res;
		local wx62_data_index = 4;--12-8,7,6
		logic.auto_login(wx62_data_res[wx62_data_index][1],wx62_data_res[wx62_data_index][2],wx62_data_res[wx62_data_index][3]);
		sys.msleep(1000);
		
	end
	if dialog_conf == "自动修改昵称" then
		--下载微信昵称
		local wx_nickname_file_url = "http://ykt.bichonfrise.cn/wxtools/nickname.txt";
		local wx_nickname_file_path = "/private/var/wxtools/wxid2.txt";
		com.download_file_from_internet(wx_nickname_file_url,wx_nickname_file_path);
		sys.msleep(3000);
		--自动修改昵称
		--com.re_launch_wx()
		local wx_rand_nickname = com.read_rand_wx_nickname_from_txt_file(wx_nickname_file_path);
		logic.change_wx_nickanme(wx_rand_nickname);
		sys.msleep(2000);
		
	end
	if dialog_conf == "自动修改头像" then
		--下载微信头像文件
		local wx_head_image_url = "http://ykt.bichonfrise.cn/wxtools/pic.txt";
		local wx_head_image_file_path = "/private/var/wxtools/pic.txt";
		com.download_file_from_internet(wx_head_image_url,wx_head_image_file_path);
		sys.msleep(2000);
		--自动修改头像
		--com.re_launch_wx();
		local head_image_url = com.read_rand_wx_head_image_url_from_txt_file(wx_head_image_file_path);
		logic.change_head_image(head_image_url);
	end
	if dialog_conf == "自动添加好友" then
		--下载微信好友
		local frd_wxid_file_url = "http://ykt.bichonfrise.cn/wxtools/wxid.txt";
		local frd_wxid_file_path = "/private/var/wxtools/wxid2.txt";
		com.download_file_from_internet(frd_wxid_file_url,frd_wxid_file_path);
		sys.msleep(3000);
		--自动添加微信好友
		local wx_id_res = com.read_rand_wx_id_from_txt_file(frd_wxid_file_path);
		local wx_id_res_len = #wx_id_res;
		logic.add_frd(wx_id_res[1]);
		-- 循环添加好友
		--for i=wx_id_res_len,1,-1 do
		--	logic.add_frd(wx_id_res[i]);
		--end
	end
	if dialog_conf == "自动给新好友发消息" then
		--下载自动回复消息文件并自动回复
		local wx_auto_response_url = "http://ykt.bichonfrise.cn/wxtools/resp.txt";
		logic.send_new_frd_msg(wx_auto_response_url);
	end
	if dialog_conf == "自动发朋友圈" then
		--下载自动发朋友圈文件
		local wx_auto_timeline_url = "http://ykt.bichonfrise.cn/wxtools/tl.txt";
		logic.send_timeline(wx_auto_timeline_url);
	end
	if dialog_conf == "自动多余删除好友" then
	end
	]]--
	--下载字库配置文件 太大了无法下载 得手动导入
	--local tess_ocr_url = "http://ykt.bichonfrise.cn/wxtools/chi_sim.traineddata";
	--local tess_ocr_file_path = "/private/var/wxtools/chi_sim.traineddata";
	--com.download_file_from_internet(tess_ocr_url,tess_ocr_file_path);

	
	

end
main()