nicFaker = {};
local faker = nil;
local bid = "com.tencent.xin";
local plist_file = require("plist");
--faker模块相关函数------------------------------------------------------------------
--安装faker模块
function nicFaker.install_faker_module(_url)
	local faker_file = "/var/mobile/Media/1ferver/lua/XXTFaker.xxt";
	if not file.exists(faker_file) then
		local is_installed = nicFaker.update_faker(_url);
		return is_installed;
	end
	faker = require("XXTFaker")();
	faker.install();
	return true;
end
--检查更新faker模块,获取初始化faker
function nicFaker.update_faker(_url)
	local faker_file = "/var/mobile/Media/1ferver/lua/XXTFaker.xxt";
	local is_install_done = false;
	thread.dispatch(function() 
				local download_count = 0;
				while not is_install_done do
					sys.toast('Faker模块下载中.'..string.rep('.', download_count%6));
					download_count = download_count + 1;
					sys.msleep(30);
				end
			end);
	local resp_code, resp_header, resp_body = http.get(_url);
	if resp_code == 200 then
		file.writes(faker_file,resp_body);
		faker = require("XXTFaker")();
		faker.install();
		is_install_done = true;
		return true;
	end
	return false;
end

--逻辑相关函数----------------------------------------------------------------
--强制清除APP数据
function nicFaker.clear_app_data(_bid)
	app.close(_bid);
	local app_data_path = app.data_path(_bid);
	local app_data_files = file.list(app_data_path);
	for _,v  in ipairs(app_data_files) do
		local app_data_file_path = app_data_path .. "/" .. v;
		os.execute("rm -rf " .. app_data_file_path);
	end
end
function nicFaker.set_fake_app_no_clear()
	--清除设备信息
	clear.idfav();
	
	--获取随机配置
	local rand_device_config = faker.random_config();
	--设置配置
	faker.set_config(bid,rand_device_config,true);
	

	clear.keychain(bid);
	clear.all_keychain();
	clear.cookies();
end
--伪造APP信息
function nicFaker.set_fake_app()
	local is_fake_done = false;
	thread.dispatch(function() 
		local fake_count = 0;
		while not is_fake_done do
			sys.toast('伪装中.'..string.rep('.', fake_count%6));
			fake_count = fake_count + 1;
			sys.msleep(30);
		end
	end);

	--清除设备信息
	clear.idfav();
	--清除APP数据
	--clear.app_data(bid);
	nicFaker.clear_app_data(bid);
	
	--获取随机配置
	local rand_device_config = faker.random_config();
	--设置配置
	faker.set_config(bid,rand_device_config,true);
	--开始清除APP信息
	local app_data_documents = app.data_path(bid) .. "/Documents/";
	os.execute(
		table.concat(
			{
				string.format("mkdir -p %s", app_data_documents),
				string.format('chown -R mobile:mobile %s', app_data_documents),
				string.format('chmod -R 755 %s', app_data_documents),
				string.format("rm -rf %s/*", app_data_documents),
			},
			"\n"
		)
	);

	clear.keychain(bid);
	clear.all_keychain();
	clear.cookies();
	is_fake_done = true;
end
--备份APP信息
function nicFaker.backup_app(_save_keychain, _save_springboard, _file_path)
	local is_backup_done = false;
	thread.dispatch(function() 
		local backup_count = 0;
		while not is_backup_done do
			sys.toast('备份中.'..string.rep('.', backup_count%6));
			backup_count = backup_count + 1;
			sys.msleep(30);
		end
	end);

	--创建备份文件目录
	os.execute(string.format("mkdir -p %s",_file_path));

	local app_data_path = _file_path .. "/" .. bid;
	--关闭APP
	app.close(bid);
	sys.msleep(1000);
	
	local app_device_configs = {};
	--获取配置信息
	app_device_configs = faker.get_config(bid);
	--移动APP数据信息
	os.execute(
		table.concat(
			{
				string.format("mkdir -p %s", app_data_path),
				string.format("mv -f %s/* %s", app.data_path(bid), app_data_path),
			},
			"\n"
		)
	);
	--写入备份配置文件
	file.writes(_file_path .. "/t.cfg", json.encode(app_device_configs));
	file.writes(_file_path .. "/idfav.cfg", clear.idfav());
	--备份keychain信息
	if _save_keychain then
		os.execute(
			table.concat(
				{
					string.format("mkdir -p %s/keychain", _file_path),
					'killall -SIGSTOP SpringBoard',
					"cp -f -r /private/var/Keychains/keychain-2.db " .. _file_path .. "/keychain/keychain-2.db",
                   "cp -f -r /private/var/Keychains/keychain-2.db-shm " .. _file_path .. "/keychain/keychain-2.db-shm",
                   "cp -f -r /private/var/Keychains/keychain-2.db-wal " .. _file_path .. "/keychain/keychain-2.db-wal",
                   'killall -SIGCONT SpringBoard',
				},
				"\n"
			)
		);
	end
	--备份spring_board信息
	if _save_springboard then
		os.execute(
			table.concat(
				{
					string.format("mkdir -p %s/ouid", _file_path),
					'cp -f -r /var/mobile/Library/Caches/com.apple.UIKit.pboard ' .. _file_path .. '/ouid',
				},
				"\n"
			)
		);
	end
    clear.all_keychain();
    clear.pasteboard();
    clear.cookies();
	is_backup_done = true;
	return _file_path;
end
--还原备份
function nicFaker.restore_app(_account,_file_path)

	local is_restore_done = false;
	thread.dispatch(function() 
		local restore_count = 0;
		while not is_restore_done do
			sys.toast('还原中.'..string.rep('.', restore_count%6));
			restore_count = restore_count + 1;
			sys.msleep(30);
		end
	end);
	--清除账号信息
	nicFaker.clear_app_data(bid);
	--处理当前账号信息
	local current_account_plist_file_name = _file_path .. "record.plist";
	if file.exists(current_account_plist_file_name) then
		local current_account_info = plist_file.read(current_account_plist_file_name);
		if current_account_info.account == _account then
			is_restore_done = true;
			sys.toast("备份账号已登录，无需还原！");
			return true;
		end
	end
	local account_file_name = _file_path .. _account;
	local current_account_info = {};
	current_account_info.account = _account;
	plist_file.write(current_account_plist_file_name,current_account_info);
	
	if not file.exists(account_file_name) then
		sys.toast("还原文件不存在！");
		is_restore_done = true;
		return false;
	end
	
	if file.exists(account_file_name .. "/keychain") == "directory" then
		os.execute(
			table.concat(
				{
					"killall -SIGSTOP SpringBoard",
					"cp -f -r " .. account_file_name .. "/keychain/keychain-2.db /private/var/Keychains/keychain-2.db",
					"cp -f -r " .. account_file_name .. "/keychain/keychain-2.db-shm /private/var/Keychains/keychain-2.db-shm",
					"cp -f -r " .. account_file_name .. "/keychain/keychain-2.db-wal /private/var/Keychains/keychain-2.db-wal",
					"killall -SIGCONT SpringBoard",
				},
				'\n'
			)
		);
	end
	if file.exists(account_file_name .. '/ouid') == "directory" then
		os.execute(
			table.concat(
				{
					"cp -f -r " .. account_file_name.."/ouid/com.apple.UIKit.pboard /var/mobile/Library/Caches/",
				},
				'\n'
			)
		);
	end
	if file.exists(account_file_name .. "/idfav.cfg") then
		clear.idfav(file.reads(account_file_name .. "/idfav.cfg"));
	end
	local app_device_configs  = json.decode(file.reads(account_file_name .. "/t.cfg"));
	sys.log("t.cfg=" .. file.reads(account_file_name .. "/t.cfg"));
	local app_data_path = account_file_name .. "/" .. bid;
	nicFaker.clear_app_data(bid);
	os.execute("rm -rf " .. app.data_path(bid) .. "/*");
	faker.set_config(bid,app_device_configs,false);
	os.execute(
		table.concat(
			{
				string.format('mv -f %s/Documents %s', app_data_path, app.data_path(bid)),
				string.format('mv -f %s/Library %s', app_data_path, app.data_path(bid)),
				string.format('chown -R mobile:mobile %s', app.data_path(bid)),
				string.format('chmod -R 755 %s', app.data_path(bid)),
			},
			'\n'
		)
	);
	sys.log(table.concat(
			{
				string.format('mv -f %s/Documents %s', app_data_path, app.data_path(bid)),
				string.format('mv -f %s/Library %s', app_data_path, app.data_path(bid)),
				string.format('chown -R mobile:mobile %s', app.data_path(bid)),
				string.format('chmod -R 755 %s', app.data_path(bid)),
			},
			'\n'
		));
	--删除原备份文件
	os.execute("rm -rf " .. account_file_name);
	clear.cookies();
	is_restore_done = true;
end
--清除所有记录
function nicFaker.clear_all_backup_record(_file_path)
	local is_clear_done = false;
	thread.dispatch(function() 
		local clear_count = 0;
		while not is_clear_done do
			sys.toast('清除中.'..stringrep('.', clear_count%6));
			clear_count = clear_count + 1;
			sys.msleep(30);
		end
	end);
	if file.exists(_file_path .. "record.plist") then
		os.execute(
			'rm -rf ' .. _file_path .. '*'
		);
		sys.toast("已清除所有备份！");
	end
	is_clear_done = true;
end
--检测账号备份是否存在
function nicFaker.check_account_backup_record(_account,_file_path)
	if file.exists(_file_path .. _account) then
		return true;
	end
	return false;
end
-- 一键新机操作
function nicFaker.one_key_new_device(_account, _file_path)
	local is_account_backup_record_exist = nicFaker.check_account_backup_record(_account, _file_path);
	if is_account_backup_record_exist == true then
		nicFaker.restore_app(_account,_file_path);
		sys.toast("账号:" .. _account .. "备份文件存在,还原成功！");
	else
		nicFaker.set_fake_app();
		sys.toast("账号:" .. _account .. "备份不文件存在,一键新机成功！")
	end
end
return nicFaker;