extends Control

# BUGS:
#	- Install a patch then change languages throws N/A2 errors

var storage_path
var dlStatus
var dlBytes
var dlSize
var dlProgress
onready var download_status = get_node("../conMain/lblStatus")

var settings: Dictionary = {
	"Logging": false,
	"Setup": false,
	"Stats": true,
	"UpdateCheck": true,
	"Version": "1.0",
	"Language": "english"
}

var packDirs: Dictionary = {
	"One": "",
	"Two": "",
	"Three": "",
	"Four": "",
	"Five": "",
	"Six": "",
	"Seven": "",
	"Eight": "",
	"SAq1": "",
	"SAq2": "",
	"SAfxl": "",
	"SAd2": "",
	"SAuyw": "",
	"SAwtd": ""
}

var remoteVersions: Dictionary = {
	"pp1": "",
	"pp2": "",
	"pp3": "",
	"pp4": "",
	"pp5": "",
	"pp6": "",
	"pp7": "",
	"pp8": "",
	"qp1": "",
	"qp2": "",
	"dr2": "",
	"fxl": "",
	"uyw": "",
	"wtd": "",
}

var weblocations: Dictionary = {}
var labelNA: String = "\n[color=pink]N/A[/color]"

func packNumToWord(sGamePack: String) -> String:
	match sGamePack:
		"1": return "One"
		"2": return "Two"
		"3": return "Three"
		"4": return "Four"
		"5": return "Five"
		"6": return "Six"
		"7": return "Seven"
		"8": return "Eight"
		"0": return "Zero"
		"E": return "Extra"
	return ""
func packWordToNum(sGamePack: String) -> String:
	match sGamePack:
		"One": return "1"
		"Two": return "2"
		"Three": return "3"
		"Four": return "4"
		"Five": return "5"
		"Six": return "6"
		"Seven": return "7"
		"Eight": return "8"
		"Zero": return "0"
		"Extra": return "E"
	return ""
func packIDToText(packID: String) -> String:
	match packID:
		"pp1": return "Party Pack 1"
		"pp2": return "Party Pack 2"
		"pp3": return "Party Pack 3"
		"pp4": return "Party Pack 4"
		"pp5": return "Party Pack 5"
		"pp6": return "Party Pack 6"
		"pp7": return "Party Pack 7"
		"pp8": return "Party Pack 8"
		"qp1": return "Quiplash 1"
		"qp2": return "Quiplash 2"
		"dr2": return "Drawful 2"
		"fxl": return "Fibbage XL"
		"wtd": return "What The Dub"
		"uyw": return "Use Your Words"
	return ""
	
func readConfig(sSection: String, sKey: String, bMode: bool, sINIFile: String = "jbppp_settings.ini") -> String:
	var config = ConfigFile.new()
	config.load("./" + sINIFile)
	if config.has_section_key(sSection, sKey):
		return config.get_value(sSection, sKey)
	else:
		if bMode:
			return "false"
		else:
			return ""

func logLine(sMsg: String):
	var file = File.new()
	var tStamp = OS.get_datetime()
	file.open("./debug_log.txt", File.WRITE)
	file.seek_end()
	file.store_line(str(tStamp.month)+"/"+str(tStamp.day)+"/"+str(tStamp.year)+"/ "+str(tStamp.hour)+":"+str(tStamp.minute) + ": " + sMsg)
	file.close()

func _process(delta):
	dlStatus = $HTTPRequest.get_http_client_status()
	dlBytes = $HTTPRequest.get_downloaded_bytes()
	dlSize = $HTTPRequest.get_body_size()
	if dlStatus == 6 or dlStatus == 3 or dlStatus == 1:
		download_status.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_CONNECTING", "Connecting to Server...")
	elif dlStatus == 7:
		dlProgress = (dlBytes * 100 / dlSize) 
		download_status.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_DOWNLOADING", "Downloading...")
		$ProgressBar.value = dlProgress
	elif dlStatus == 5:
		download_status.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_CONNECTED", "Server Connected!")
	elif dlStatus == 4 or dlStatus == 2:
		download_status.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_CONNECTFAIL", "Can't connect to the Server.")
	else:
		download_status.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_ERROR", "Unknown Error")
	
func _ready():	
	set_process(false)
	get_node("../conLoading").show()	
	
	var file = File.new()
	if file.file_exists("./jbppp_settings.ini"):
		if settings.Logging: logLine("Loading Existing Config")
		settings.Logging = bool(readConfig("Settings", "Logging", true))
		settings.Setup = bool(readConfig("Settings", "Setup", true))
		settings.Stats = bool(readConfig("Settings", "Stats", true))
		settings.UpdateCheck = bool(readConfig("Settings", "UpdateCheck", true))
		settings.Version = str(readConfig("Main", "Version", false))
		settings.Language = str(readConfig("Main", "Language", false))				
		packDirs.One = str(readConfig("Packs", "One", false))
		packDirs.Two = str(readConfig("Packs", "Two", false))
		packDirs.Three = str(readConfig("Packs", "Three", false))
		packDirs.Four = str(readConfig("Packs", "Four", false))
		packDirs.Five = str(readConfig("Packs", "Five", false))
		packDirs.Six = str(readConfig("Packs", "Six", false))
		packDirs.Seven = str(readConfig("Packs", "Seven", false))
		packDirs.Eight = str(readConfig("Packs", "Eight", false))		
		packDirs.SAq1 = str(readConfig("Packs", "SAq1", false))
		packDirs.SAq2 = str(readConfig("Packs", "SAq2", false))
		packDirs.SAfxl = str(readConfig("Packs", "SAfxl", false))
		packDirs.SAd2 = str(readConfig("Packs", "SAd2", false))
		packDirs.SAwtd = str(readConfig("Packs", "SAwtd", false))
		packDirs.SAuyw = str(readConfig("Packs", "SAuyw", false))
	else:
		if settings.Logging: logLine("No Config Found, Creating...")
		var config = ConfigFile.new()
		config.set_value("Main", "Version", settings.Version)
		config.set_value("Main", "Language", settings.Language)
		config.set_value("Settings", "Logging", settings.Logging)
		config.set_value("Settings", "Setup", settings.Setup)
		config.set_value("Settings", "Stats", settings.Stats)
		config.set_value("Packs", "One", "")
		config.set_value("Packs", "Two", "")
		config.set_value("Packs", "Three", "")
		config.set_value("Packs", "Four", "")
		config.set_value("Packs", "Five", "")
		config.set_value("Packs", "Six", "")
		config.set_value("Packs", "Seven", "")
		config.set_value("Packs", "Eight", "")
		config.set_value("Packs", "SAq1", "")
		config.set_value("Packs", "SAq2", "")
		config.set_value("Packs", "SAfxl", "")
		config.set_value("Packs", "SAd2", "")
		config.set_value("Packs", "SAuyw", "")
		config.set_value("Packs", "SAwtd", "")
		config.save("./jbppp_settings.ini")
		if settings.Logging: logLine("New Default Configuration Saved")	
	file.close()
	
	file = File.new()
	if not file.file_exists("./locations.json"):
		OS.alert(getLangMessage(settings.Language, "APP_ERROR_MISSING_LOCATIONS", "locations.json is missing."))
		get_tree().quit(0)
	file.close()
	weblocations = parse_json(loadLocations())
	
	var dir = Directory.new()
	dir.open("./languages/")
	dir.list_dir_begin()
	#get_node("../conSetup/optLang").add_item("english")
	while true:
		var filel = dir.get_next()
		if filel == "":
			break
		elif not filel.begins_with(".") and filel.ends_with("json"):
			get_node("../conSetup/optLang").add_item(filel.replace(".json", "").capitalize())
			if filel == settings.Language:
				get_node("../conSetup/optLang").select(get_node("../conSetup/optLang").get_item_count()-1)
	dir.list_dir_end()
	
	get_node("../conLoading/lblDisclaimer").text = getLangMessage(settings.Language, "APP_DISCLAIMER", "This software is fan made and not supported by Jackbox Games, Smiling Buddha Games, or Wide Right Interactive. Do not contact them for assistance related to this software. This is free software, if you paid for it then you were scammed. This software comes with no warranty.")
	
	if !settings.Setup:
		get_node("../conLoading").hide()
		get_node("../conMain").hide()
		get_node("../conSetup").show()
	else:
		#get_node("../conMain").show()
		get_node("../conSetup").hide()
		validatePaths()
		loadPathsForSetup()
		newLang(settings.Language)
		callVersionLoads()
		checkVersions()
	
func reloadpackDirs():
	packDirs.One = str(readConfig("Packs", "One", false))
	packDirs.Two = str(readConfig("Packs", "Two", false))
	packDirs.Three = str(readConfig("Packs", "Three", false))
	packDirs.Four = str(readConfig("Packs", "Four", false))
	packDirs.Five = str(readConfig("Packs", "Five", false))
	packDirs.Six = str(readConfig("Packs", "Six", false))
	packDirs.Seven = str(readConfig("Packs", "Seven", false))
	packDirs.Eight = str(readConfig("Packs", "Eight", false))		
	packDirs.SAq1 = str(readConfig("Packs", "SAq1", false))
	packDirs.SAq2 = str(readConfig("Packs", "SAq2", false))
	packDirs.SAd2 = str(readConfig("Packs", "SAd2", false))
	packDirs.SAfxl = str(readConfig("Packs", "SAfxl", false))
	packDirs.SAuyw = str(readConfig("Packs", "SAuyw", false))
	packDirs.SAwtd = str(readConfig("Packs", "SAwtd", false))
	
func validatePaths():
	var config = ConfigFile.new()
	var file = File.new()
	config.load("./jbppp_settings.ini")
	if not file.file_exists(packDirs.One): 
		config.set_value("Packs", "One", "")
		packDirs.One = ""
	if not file.file_exists(packDirs.Two): 
		config.set_value("Packs", "Two", "") 
		packDirs.Two = ""
	if not file.file_exists(packDirs.Three): 
		config.set_value("Packs", "Three", "") 
		packDirs.Three = ""
	if not file.file_exists(packDirs.Four): 
		config.set_value("Packs", "Four", "") 
		packDirs.Four = ""
	if not file.file_exists(packDirs.Five): 
		config.set_value("Packs", "Five", "") 
		packDirs.Five = ""
	if not file.file_exists(packDirs.Six): 
		config.set_value("Packs", "Six", "") 
		packDirs.Six = ""
	if not file.file_exists(packDirs.Seven): 
		config.set_value("Packs", "Seven", "") 
		packDirs.Seven = ""
	if not file.file_exists(packDirs.Eight): 
		config.set_value("Packs", "Eight", "") 
		packDirs.Eight = ""
	if not file.file_exists(packDirs.SAq1): 
		config.set_value("Packs", "SAq1", "") 
		packDirs.SAq1 = ""
	if not file.file_exists(packDirs.SAq2): 
		config.set_value("Packs", "SAq2", "") 
		packDirs.SAq2 = ""
	if not file.file_exists(packDirs.SAd2): 
		config.set_value("Packs", "SAd2", "") 
		packDirs.SAd2 = ""
	if not file.file_exists(packDirs.SAfxl): 
		config.set_value("Packs", "SAfxl", "") 
		packDirs.SAfxl = ""
	if not file.file_exists(packDirs.SAuyw): 
		config.set_value("Packs", "SAuyw", "") 
		packDirs.SAuyw = ""
	if not file.file_exists(packDirs.SAwtd): 
		config.set_value("Packs", "SAwtd", "") 
		packDirs.SAwtd = ""
	config.save("./jbppp_settings.ini")
	
func loadPathsForSetup():
	var file = File.new()
	if packDirs.One.length() > 3 and file.file_exists(packDirs.One): 
		get_node("../conSetup/lblPP1").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtPP1").text = packDirs.One
	if packDirs.Two.length() > 3 and file.file_exists(packDirs.Two): 
		get_node("../conSetup/lblPP2").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtPP2").text = packDirs.Two
	if packDirs.Three.length() > 3 and file.file_exists(packDirs.Three): 
		get_node("../conSetup/lblPP3").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtPP3").text = packDirs.Three
	if packDirs.Four.length() > 3 and file.file_exists(packDirs.Four): 
		get_node("../conSetup/lblPP4").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtPP4").text = packDirs.Four
	if packDirs.Five.length() > 3 and file.file_exists(packDirs.Five): 
		get_node("../conSetup/lblPP5").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtPP5").text = packDirs.Five
	if packDirs.Six.length() > 3 and file.file_exists(packDirs.Six): 
		get_node("../conSetup/lblPP6").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtPP6").text = packDirs.Six
	if packDirs.Seven.length() > 3 and file.file_exists(packDirs.Seven): 
		get_node("../conSetup/lblPP7").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtPP7").text = packDirs.Seven
	if packDirs.Eight.length() > 3 and file.file_exists(packDirs.Eight): 
		get_node("../conSetup/lblPP8").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtPP8").text = packDirs.Eight
	if packDirs.SAq1.length() > 3 and file.file_exists(packDirs.SAq1): 
		get_node("../conSetup/lblSAQuiplash").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtSAQuiplash").text = packDirs.SAq1
	if packDirs.SAq2.length() > 3 and file.file_exists(packDirs.SAq2): 
		get_node("../conSetup/lblQuiplash2").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtSAQuiplash2").text = packDirs.SAq2
	if packDirs.SAd2.length() > 3 and file.file_exists(packDirs.SAd2): 
		get_node("../conSetup/lblSADrawful2").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtSADrawful2").text = packDirs.SAd2
	if packDirs.SAfxl.length() > 3 and file.file_exists(packDirs.SAfxl): 
		get_node("../conSetup/lblSAFibbageXL").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtSAFibbageXL").text = packDirs.SAfxl
	if packDirs.SAwtd.length() > 3 and file.file_exists(packDirs.SAwtd): 
		get_node("../conSetup/lblSAWTD").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtSAWTD").text = packDirs.SAwtd
	if packDirs.SAuyw.length() > 3 and file.file_exists(packDirs.SAuyw): 
		get_node("../conSetup/lblSAUYW").add_color_override("font_color", Color(0,1,0,1))
		get_node("../conSetup/txtSAUYW").text = packDirs.SAuyw
	file.close()
	
func githubRequest(packText: String, btn: Button, lbl: RichTextLabel, numCount):
	get_node("../conLoading/lblLoading").text = getLangMessage(settings.Language, "APP_LOADING", "Loading...") + "\n"+numCount as String+"/14"
	var ret
	if !weblocations.has(settings.Language.replace(".json", "")):
		btn.disabled = true
		lbl.bbcode_text = lbl.text + "\n" + getLangMessage(settings.Language, "APP_ERROR_INVALID_LANGUAGE", "Invalid Language")
		$HTTPRequest.request("https://www.blank.org/", ["mode: remote_version_check", "pack: " + packText])
		ret = yield($HTTPRequest, "request_completed")
		return ""
	if !weblocations[settings.Language.replace(".json", "")]["version"].has(packText):
		btn.disabled = true
		lbl.bbcode_text = lbl.text + "\n" + getLangMessage(settings.Language, "APP_ERROR_INVALID_LANGUAGE", "Invalid Language")
		$HTTPRequest.request("https://www.blank.org/", ["mode: remote_version_check", "pack: " + packText])
		ret = yield($HTTPRequest, "request_completed")
		return ""
	if !packText in weblocations[settings.Language.replace(".json", "")]["version"]:
		btn.disabled = true
		lbl.bbcode_text = lbl.text + "\n" + getLangMessage(settings.Language, "MAIN_NO_PATCH_FOR_GAME", "No Patch Available")
		$HTTPRequest.request("https://www.blank.org/", ["mode: remote_version_check", "pack: " + packText])
		ret = yield($HTTPRequest, "request_completed")
	else:
		if weblocations[settings.Language.replace(".json", "")]["version"][packText].length() <= 0:
			btn.disabled = true
			lbl.bbcode_text = lbl.text + "\n" + getLangMessage(settings.Language, "MAIN_NO_PATCH_FOR_GAME", "No Patch Available")
			$HTTPRequest.request("https://www.blank.org/", ["mode: remote_version_check", "pack: " + packText])
			ret = yield($HTTPRequest, "request_completed")
		else:
			$HTTPRequest.request(weblocations[settings.Language.replace(".json", "")]["version"][packText], ["mode: remote_version_check", "pack: " + packText])
			ret = yield($HTTPRequest, "request_completed")

func compareNewVersions(vlocal: String, vremote: String, ulabel: RichTextLabel):
	if vlocal != vremote:
		ulabel.bbcode_text = vlocal + "\n[color=#1E8EFF]" + getLangMessage(settings.Language, "MAIN_PATCH_UPDATE", "Available") +" v" + vremote + "[/color]"	
	else:
		ulabel.bbcode_text = vlocal + "\n[color=#32CB32]" + getLangMessage(settings.Language, "MAIN_GAME_PATCH_UPTODATE", "Up To Date") + "[/color]"

func checkVersions():
	var retu
	retu = yield(githubRequest("pp1", $pp1/cmdpp1, $pp1/lblpp1, 1), "completed")
	retu = yield(githubRequest("pp2", $pp2/cmdpp2, $pp2/lblpp2, 2), "completed")
	retu = yield(githubRequest("pp3", $pp3/cmdpp3, $pp3/lblpp3, 3), "completed")
	retu = yield(githubRequest("pp4", $pp4/cmdpp4, $pp4/lblpp4, 4), "completed")
	retu = yield(githubRequest("pp5", $pp5/cmdpp5, $pp5/lblpp5, 5), "completed")
	retu = yield(githubRequest("pp6", $pp6/cmdpp6, $pp6/lblpp6, 6), "completed")
	retu = yield(githubRequest("pp7", $pp7/cmdpp7, $pp7/lblpp7, 7), "completed")
	retu = yield(githubRequest("pp8", $pp8/cmdpp8, $pp8/lblpp8, 8), "completed")
	retu = yield(githubRequest("qp1", $quiplash/cmdppquip, $quiplash/lblppq, 9), "completed")
	retu = yield(githubRequest("qp2", $quiplash2/cmdppquip2, $quiplash2/lblppq2, 10), "completed")
	retu = yield(githubRequest("dr2", $drawful2/cmdd2, $drawful2/lbld2, 11), "completed")
	retu = yield(githubRequest("fxl", $fibbagexl/cmdfxl, $fibbagexl/lblfxl, 12), "completed")
	retu = yield(githubRequest("uyw", $useyourwords/cmduyw, $useyourwords/lbluyw, 13), "completed")
	retu = yield(githubRequest("wtd", $whatthedub/cmdwtd, $whatthedub/lblwtd, 14), "completed")
	get_node("../conLoading").hide()
	get_node("../conMain").show()
	
func callVersionLoads():
	$pp1/lblpp1.text = loadLocalVersion(packDirs.One, "config.jet")
	$pp2/lblpp2.text = loadLocalVersion(packDirs.Two, "config.jet")
	$pp3/lblpp3.text = loadLocalVersion(packDirs.Three, "config.jet")
	$pp4/lblpp4.text = loadLocalVersion(packDirs.Four, "config.jet")
	$pp5/lblpp5.text = loadLocalVersion(packDirs.Five, "config.jet")
	$pp6/lblpp6.text = loadLocalVersion(packDirs.Six, "config.jet")
	$pp7/lblpp7.text = loadLocalVersion(packDirs.Seven, "config.jet")
	$pp8/lblpp8.text = loadLocalVersion(packDirs.Eight, "config.jet")	
	$quiplash/lblppq.text = loadLocalVersion(packDirs.SAq1, "jbg.config.jet")
	$quiplash2/lblppq2.text = loadLocalVersion(packDirs.SAq2, "jbg.config.jet")
	$drawful2/lbld2.text = loadLocalVersion(packDirs.SAd2, "jbg.config.jet")
	$fibbagexl/lblfxl.text = loadLocalVersion(packDirs.SAfxl, "jbg.config.jet")
	$useyourwords/lbluyw.text = loadLocalVersion(packDirs.SAuyw, "version.dat")
	$whatthedub/lblwtd.text = loadLocalVersion(packDirs.SAwtd, "version.dat")
	
func loadLocalVersion(gamePath: String, gameFile: String):
	gamePath = gamePath.get_base_dir() + "/"
	if gamePath.length() < 5: return "---"
	var gfile = File.new()
	if gfile.file_exists(gamePath + gameFile):
		var vfile = File.new()
		vfile.open(gamePath + gameFile, vfile.READ)
		var gcontent = vfile.get_as_text()
		vfile.close()
		var regex = RegEx.new()
		regex.compile("(?<=buildVersion\":\")(.*)(?=\")")
		var result = regex.search(gcontent)
		var resultString = result.get_string()
		resultString = resultString.replace("Build:", "")
		resultString = resultString.replace(" ", "")
		if "-" in resultString:
			return resultString #+ "\n" + "(Patched)"
		else:
			return resultString
	else:
		return "???"

func getLangMessage(langName: String, langKey: String, langDefault: String):
	var lang = {}
	lang = parse_json(loadLang(langName))
	return applyLang(lang, langKey, langDefault)

func newLang(langName: String):	
	var lang = {}
	lang = parse_json(loadLang(langName))
	
	settings.Language = langName
	OS.set_window_title("JBPPP+ (" + settings.Language.replace(".json", "").capitalize() + ") - " + settings.Version)
	
	$pp1/cmdpp1.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$pp2/cmdpp2.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$pp3/cmdpp3.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$pp4/cmdpp4.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$pp5/cmdpp5.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$pp6/cmdpp6.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$pp7/cmdpp7.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$pp8/cmdpp8.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")	
	$quiplash/cmdppquip.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$quiplash2/cmdppquip2.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$drawful2/cmdd2.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$fibbagexl/cmdfxl.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$useyourwords/cmduyw.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$whatthedub/cmdwtd.text = applyLang(lang, "MAIN_INSTALL_PATCH", "Install Patch")
	$cmdRunSetup.text = applyLang(lang, "MAIN_RUN_SETUP", "Run Setup")	
	$lblInstalledLeft.text = applyLang(lang, "MAIN_INSTALLED_VERSION","Installed Version") 
	$lblInstalledRight.text = applyLang(lang, "MAIN_INSTALLED_VERSION", "Installed Version")
	$lblStatus.text = "..."
	$ProgressBar.value = 0
	
	get_node("../conLoading/lblDisclaimer").text = getLangMessage(settings.Language, "APP_DISCLAIMER", "This software is fan made and not supported by Jackbox Games, Smiling Buddha Games, or Wide Right Interactive. Do not contact them for assistance related to this software. This is free software, if you paid for it then you were scammed. This software comes with no warranty.")
	
	$"../conSetup/cmdPP1".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdPP2".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdPP3".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdPP4".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdPP5".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdPP6".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdPP7".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdPP8".text = applyLang(lang, "SETUP_BROWSE", "Browse")	
	$"../conSetup/cmdSAQuiplash".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdSAQuiplash2".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdSADrawful2".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdSAFibbageXL".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdSAWTD".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdSAUYW".text = applyLang(lang, "SETUP_BROWSE", "Browse")
	$"../conSetup/cmdAuto".text = applyLang(lang, "SETUP_ATTEMPT_AUTO_DETECT", "Attempt Auto Detect")
	$"../conSetup/cmdSave".text = applyLang(lang, "SETUP_SAVE_CONTINUE", "Save & Continue")	
	$"../conSetup/lblsaheader".text = applyLang(lang, "SETUP_STAND_ALONE_GAMES", "Stand Alone Games")	
	$"../conSetup/lbljbheader".text = applyLang(lang, "SETUP_JACKBOX_PACK_LOCATIONS", "Jackbox Pack Locations")	
	$"../conSetup/lblHeader".text = applyLang(lang, "SETUP_HEADER", "Welcome to Jackbox Party Pack Patcher - The All-in-one Localization Patcher.\nPlease select the executable for each game listed below then Save to proceed.\nGreen titles mean it's a valid path.")
	
func applyLang(langDic: Dictionary, langKey: String, defaultString: String):
	if langDic.has(langKey):
		return langDic[langKey]
	else:
		return defaultString

func loadLocations():
	var locFile = File.new()
	locFile.open("./locations.json", locFile.READ)
	var locFileText = locFile.get_as_text()
	locFile.close()
	return locFileText	

func loadLang(sLang: String):
	var langFile = File.new()
	langFile.open("./languages/" + sLang, langFile.READ)
	var langFileText = langFile.get_as_text()
	langFile.close()
	return langFileText

func _on_cmdRunSetup_pressed():
	get_node("../conMain").hide()
	get_node("../conSetup").show()

func afterHTTPRemoteVersion(sHeader: String, sBody: String):
	var lbl: RichTextLabel
	var btn: Button
	match sHeader:
		"pp1": 
			lbl = $pp1/lblpp1
			btn = $pp1/cmdpp1
		"pp2": 
			lbl = $pp2/lblpp2
			btn = $pp2/cmdpp2
		"pp3": 
			lbl = $pp3/lblpp3
			btn = $pp3/cmdpp3
		"pp4":
			lbl = $pp4/lblpp4
			btn = $pp4/cmdpp4
		"pp5": 
			lbl = $pp5/lblpp5
			btn = $pp5/cmdpp5
		"pp6": 
			lbl = $pp6/lblpp6
			btn = $pp6/cmdpp6
		"pp7": 
			lbl = $pp7/lblpp7
			btn = $pp7/cmdpp7
		"pp8":
			lbl = $pp8/lblpp8
			btn = $pp8/cmdpp8
		"qp1": 
			lbl = $quiplash/lblppq
			btn = $quiplash/cmdppquip
		"qp2": 
			lbl = $quiplash2/lblppq2
			btn = $quiplash2/cmdppquip2
		"dr2": 
			lbl = $drawful2/lbld2
			btn = $drawful2/cmdd2
		"fxl": 
			lbl = $fibbagexl/lblfxl
			btn = $fibbagexl/cmdfxl
		"uyw": 
			lbl = $useyourwords/lbluyw
			btn = $useyourwords/cmduyw
		"wtd": 
			lbl = $whatthedub/lblwtd
			btn = $whatthedub/cmdwtd
	
	if lbl.text == "---":
		lbl.bbcode_text = lbl.text + "\n" + getLangMessage(settings.Language, "MAIN_GAME_MISSING", "Game Not Found")
		btn.disabled = true
		return "N/A"
		
	if not weblocations.has(settings.Language.replace(".json", "")):
		lbl.bbcode_text = lbl.text + labelNA + "1"
		btn.disabled = true
		return "N/A"	
	
	if sBody.length() < 4: 
		lbl.bbcode_text = lbl.text + labelNA + "2"
		btn.disabled = true
		return "N/A"
	if "buildVersion" in sBody:
		var regex = RegEx.new()
		regex.compile("(?<=buildVersion\":\")(.*)(?=\")")
		var regres = regex.search(sBody)
		var regText: String = regres.get_string()
		regText = regText.replace("Build:", "")
		regText = regText.replace(" ", "")
		var regLeft = regText.split("-", true, 1)
		#if typeof(regLeft) == TYPE_ARRAY:
		var regLangVer = regLeft[0].split(".", true, 1)
		
		if "-" in lbl.text:
			var localLeft = lbl.text.split("-", true, 1)
			if localLeft.size() <= 0: 
				lbl.bbcode_text = lbl.text + labelNA + "3"
				btn.disabled = true
				return "N/A"
			var localLangVer = localLeft[0].split(".", true, 1)
			if localLangVer.size() <= 0: 
				lbl.bbcode_text = lbl.text + labelNA + "4"
				btn.disabled = true
				return "N/A"
			if regLangVer.size() <= 0: 
				lbl.bbcode_text = lbl.text + labelNA + "5"
				btn.disabled = true
				return "N/A"
			if localLangVer[1] != regLangVer[1] or regLeft[1] != localLeft[1]:
				updateRemoteVersionDict(sHeader, regText as String)
				lbl.bbcode_text = lbl.text + "\n[color=#1E8EFF]" + getLangMessage(settings.Language, "MAIN_PATCH_UPDATE", "Available") +" v" + regText as String + "[/color]"
				if "-" in lbl.text:
					btn.text = getLangMessage(settings.Language, "MAIN_UPDATE_PATCH", "Update Patch")
				else:
					btn.text = getLangMessage(settings.Language, "MAIN_INSTALL_PATCH", "Install Patch")
				btn.disabled = false
				return "N/A"
			else:
				updateRemoteVersionDict(sHeader, regText as String)
				lbl.bbcode_text = lbl.text + "\n[color=#32CB32]" + getLangMessage(settings.Language, "MAIN_GAME_PATCH_UPTODATE", "Up To Date") + "[/color]"
				if "-" in lbl.text:
					btn.text = getLangMessage(settings.Language, "MAIN_UPDATE_PATCH", "Update Patch")
				else:
					btn.text = getLangMessage(settings.Language, "MAIN_INSTALL_PATCH", "Install Patch")
				btn.disabled = true
				return "N/A"
		else:
			updateRemoteVersionDict(sHeader, regText as String)
			lbl.bbcode_text = lbl.text + "\n[color=#1E8EFF]" + getLangMessage(settings.Language, "MAIN_PATCH_UPDATE", "Available") + " v" + regText as String + "[/color]"
			btn.disabled = false
			return "N/A"
		return regLangVer[1] as String
	else:
		lbl.bbcode_text = lbl.text
		btn.disabled = true
		return "N/A"

func updateRemoteVersionDict(sPack: String, remoteV: String):
	print(sPack + " is now version " + remoteV)
	match sPack:
		"pp1": remoteVersions.pp1 = remoteV
		"pp2": remoteVersions.pp2 = remoteV
		"pp3": remoteVersions.pp3 = remoteV
		"pp4": remoteVersions.pp4 = remoteV
		"pp5": remoteVersions.pp5 = remoteV
		"pp6": remoteVersions.pp6 = remoteV
		"pp7": remoteVersions.pp7 = remoteV
		"pp8": remoteVersions.pp8 = remoteV
		"qp1": remoteVersions.qp1 = remoteV
		"qp2": remoteVersions.qp2 = remoteV
		"dr2": remoteVersions.dr2 = remoteV
		"fxl": remoteVersions.fxl = remoteV
		"uyw": remoteVersions.wtd = remoteV
		"wtd": remoteVersions.uyw = remoteV

func unzip(sourceFile,destination):
	storage_path = destination
	print("unzip: " + sourceFile)
	var file = File.new()
	if !file.file_exists(sourceFile):
		return "Missing Zip"
	set_process(false)
	$lblStatus.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_EXTRACTING", "Extracting...")
	var gdunzip = load('res://addons/gdunzip/gdunzip.gd').new()
	var loaded = gdunzip.load(sourceFile)
	if !loaded:
		$lblStatus.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_BADURL", "Failed! Bad URL")
		return "Bad URL"
	ProjectSettings.load_resource_pack(sourceFile)
	var i = 0
	for f in gdunzip.files:
		unzip_file(f)
	$ProgressBar.value = 100
	return "Done"
		
func unzip_file(fileName):
	var readFile = File.new()
	if readFile.file_exists("res://" + fileName):
		readFile.open(("res://" + fileName), File.READ)
		var content = readFile.get_buffer(readFile.get_len())
		readFile.close()
		var base_dir = storage_path + fileName.get_base_dir()
		var dir = Directory.new()
		dir.make_dir(base_dir)
		var writeFile = File.new()
		writeFile.open(storage_path + fileName, File.WRITE)
		writeFile.store_buffer(content)
		writeFile.close()
	else:
		print("failed: " + OS.get_executable_path().get_base_dir() + "/" + fileName)

func refreshVersion(sPack: String):	
	var retu
	match sPack:
		"pp1": compareNewVersions(loadLocalVersion(packDirs.One, "config.jet"), remoteVersions.pp1, $pp1/lblpp1)
		"pp2": compareNewVersions(loadLocalVersion(packDirs.Two, "config.jet"), remoteVersions.pp2, $pp2/lblpp2)
		"pp3": compareNewVersions(loadLocalVersion(packDirs.Three, "config.jet"), remoteVersions.pp3, $pp3/lblpp3)
		"pp4": compareNewVersions(loadLocalVersion(packDirs.Four, "config.jet"), remoteVersions.pp4, $pp4/lblpp4)
		"pp5": compareNewVersions(loadLocalVersion(packDirs.Five, "config.jet"), remoteVersions.pp5, $pp5/lblpp5)
		"pp6": compareNewVersions(loadLocalVersion(packDirs.Six, "config.jet"), remoteVersions.pp6, $pp6/lblpp6)
		"pp7": compareNewVersions(loadLocalVersion(packDirs.Seven, "config.jet"), remoteVersions.pp7, $pp7/lblpp7)
		"pp8": compareNewVersions(loadLocalVersion(packDirs.Eight, "config.jet"), remoteVersions.pp8, $pp8/lblpp8)
		"qp1": compareNewVersions(loadLocalVersion(packDirs.SAq1, "jbg.config.jet"), remoteVersions.qp1, $quiplash/lblppq)
		"qp2": compareNewVersions(loadLocalVersion(packDirs.SAq2, "jbg.config.jet"), remoteVersions.qp2, $quiplash2/lblppq2)
		"dr2": compareNewVersions(loadLocalVersion(packDirs.SAd2, "jbg.config.jet"), remoteVersions.dr2, $drawful2/lbld2)
		"fxl": compareNewVersions(loadLocalVersion(packDirs.SAfxl, "jbg.config.jet"), remoteVersions.fxl, $fibbagexl/lblfxl)
		"wtd": compareNewVersions(loadLocalVersion(packDirs.SAuyw, "version.dat"), remoteVersions.wtd, $useyourwords/lbluyw)
		"uyw": compareNewVersions(loadLocalVersion(packDirs.SAwtd, "version.dat"), remoteVersions.uyw, $whatthedub/lblwtd)

func getPackDir(sPack: String):
	match sPack:
		"pp1": return packDirs.One
		"pp2": return packDirs.Two
		"pp3": return packDirs.Three
		"pp4": return packDirs.Four
		"pp5": return packDirs.Five
		"pp6": return packDirs.Six
		"pp7": return packDirs.Seven
		"pp8": return packDirs.Eight
		"qp1": return packDirs.SAq1
		"qp2": return packDirs.SAq2
		"dr2": return packDirs.SAd2
		"fxl": return packDirs.SAfxl
		"wtd": return packDirs.SAwtd
		"uyw": return packDirs.SAuyw
	return ""

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var sPack
	var ret
	if "remote_version_check" in headers[0]:
		sPack = headers[1].split(" ")
		afterHTTPRemoteVersion(sPack[1], body.get_string_from_utf8())
	elif "download_pack" in headers[0]:
		set_process(false)
		sPack = headers[1].split(" ")
		$lblStatus.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_EXTRACTING", "Extracting...")
		print("user://" + sPack[1] + ".zip => " + getPackDir(sPack[1]).get_base_dir() + "/")
		ret = unzip("user://" + sPack[1] + ".zip", getPackDir(sPack[1]).get_base_dir() + "/")				
		refreshVersion(sPack[1])
		unlockButtons($pp1/cmdpp1)
		$lblStatus.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_INSTALLED", "Installed {} Patch").replace("{}", packIDToText(sPack[1]))
		$ProgressBar.value = 100
	set_process(false)

func lockButtons(exceptBtn: Button):
	$pp1/cmdpp1.visible = false
	$pp2/cmdpp2.visible = false
	$pp3/cmdpp3.visible = false
	$pp4/cmdpp4.visible = false
	$pp5/cmdpp5.visible = false
	$pp6/cmdpp6.visible = false
	$pp7/cmdpp7.visible = false
	$pp8/cmdpp8.visible = false
	$quiplash/cmdppquip.visible = false
	$quiplash2/cmdppquip2.visible = false
	$fibbagexl/cmdfxl.visible = false
	$drawful2/cmdd2.visible = false
	$useyourwords/cmduyw.visible = false
	$whatthedub/cmdwtd.visible = false
	$cmdRunSetup.visible = false
	exceptBtn.visible = true
	exceptBtn.disabled = true
	
func unlockButtons(exceptBtn: Button):
	$pp1/cmdpp1.visible = true
	$pp2/cmdpp2.visible = true
	$pp3/cmdpp3.visible = true
	$pp4/cmdpp4.visible = true
	$pp5/cmdpp5.visible = true
	$pp6/cmdpp6.visible = true
	$pp7/cmdpp7.visible = true
	$pp8/cmdpp8.visible = true
	$quiplash/cmdppquip.visible = true
	$quiplash2/cmdppquip2.visible = true
	$fibbagexl/cmdfxl.visible = true
	$drawful2/cmdd2.visible = true
	$useyourwords/cmduyw.visible = true
	$whatthedub/cmdwtd.visible = true
	$cmdRunSetup.visible = true
	exceptBtn.disabled = false

func handleCmdDownload(packNum: String, theBtn: Button):
	var msg: String = getLangMessage(settings.Language, "APP_LANG_THANKS", "")
	if msg.length() > 0:
		msg = msg + "\n" + getLangMessage(settings.Language, "APP_LANG_MESSAGE", "")
	else:
		msg = getLangMessage(settings.Language, "APP_LANG_MESSAGE", "")
	if msg.length() > 0: OS.alert(msg)
	
	var ret
	$lblStatus.text = getLangMessage(settings.Language, "MAIN_DOWNLOAD_DOWNLOADING", "Downloading...")
	lockButtons(theBtn)	
	$ProgressBar.visible = true
	$ProgressBar.percent_visible = true
	print("user://" + packNum + ".zip")
	$HTTPRequest.set_download_file("user://" + packNum + ".zip")
	print("Download: " + weblocations[settings.Language.replace(".json", "")]["patch"][packNum], ["mode: download_pack", "pack: " + packNum])
	$HTTPRequest.request(weblocations[settings.Language.replace(".json", "")]["patch"][packNum], ["mode: download_pack", "pack: " + packNum])
	set_process(true)
	ret = yield($HTTPRequest, "request_completed")
	set_process(false)
	$ProgressBar.percent_visible = true

func _on_cmdpp1_pressed():
	handleCmdDownload("pp1", $pp1/cmdpp1)
func _on_cmdpp2_pressed():
	handleCmdDownload("pp2", $pp2/cmdpp2)
func _on_cmdpp3_pressed():
	handleCmdDownload("pp3", $pp3/cmdpp3)
func _on_cmdpp4_pressed():
	handleCmdDownload("pp4", $pp4/cmdpp4)
func _on_cmdpp5_pressed():
	handleCmdDownload("pp5", $pp5/cmdpp5)
func _on_cmdpp6_pressed():
	handleCmdDownload("pp6", $pp6/cmdpp6)
func _on_cmdpp7_pressed():
	handleCmdDownload("pp7", $pp7/cmdpp7)
func _on_cmdpp8_pressed():
	handleCmdDownload("pp8", $pp8/cmdpp8)
func _on_cmdppquip_pressed():
	handleCmdDownload("qp1", $quiplash/cmdppquip)
func _on_cmdppquip2_pressed():
	handleCmdDownload("qp2", $quiplash2/cmdppquip2)
func _on_cmdfxl_pressed():
	handleCmdDownload("fxl", $fibbagexl/cmdfxl)
func _on_cmdd2_pressed():
	handleCmdDownload("dr2", $drawful2/cmdd2)
func _on_cmduyw_pressed():
	handleCmdDownload("uyw", $useyourwords/cmduyw)
func _on_cmdwtd_pressed():
	handleCmdDownload("wtd", $whatthedub/cmdwtd)
