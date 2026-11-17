#!/system/bin/sh

MODULE_ID="ghxnb"
MODULE_AUTHOR="加q群1058272764"
LOG_FILE="/data/local/tmp/RUN.log"
STATE_FILE="/data/local/tmp/.RUN_state"
MIN_HZ="60.0"
MAX_HZ="120.0"
TOUCH_TIMEOUT=1000

SDK="$(getprop ro.build.version.sdk)"
ANDROID="$(getprop ro.build.version.release)"
GPU="$(getprop ro.hardware.egl)"

case "$SDK" in
    30)       DRIVER_API="Android 11" ;;
    31|32)    DRIVER_API="Android 12" ;;
    33)       DRIVER_API="Android 13" ;;
    34)       DRIVER_API="Android 14" ;;
    35)       DRIVER_API="Android 15" ;;
    36)       DRIVER_API="Android 16" ;;
    *)        DRIVER_API="现代 Android" ;;
esac

log() {
    TS="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "$TS [游戏优化] $*"
    echo "$TS [游戏优化] $*" >> "$LOG_FILE" 2>/dev/null
}

notify() {
    cmd notification post -S bigtext -t "ghxnb" "Tag" "$1" >/dev/null 2>&1
}

banner() {
    echo "========================================"
    echo "         ghxnb"
    echo "         $1"
    echo "========================================"
}

apply_setting() {
    KEY="$1"
    VALUE="$2"
    echo "[尝试] $KEY"
    RESULT="$(settings put global "$KEY" "$VALUE" 2>&1)"
    if [ $? -eq 0 ]; then
        echo "[成功] $KEY"
    else
        echo "[被拒绝] $KEY"
        [ -n "$RESULT" ] && echo "[详情] $RESULT"
    fi
}

detect_games() {
    GAME_PACKAGES=""
    echo ""
    echo "========== 游戏检测 =========="
    for PKG in $GAME_LIST; do
        if pm path "$PKG" >/dev/null 2>&1; then
            echo "[已找到] $PKG"
            if [ -z "$GAME_PACKAGES" ]; then
                GAME_PACKAGES="$PKG"
            else
                GAME_PACKAGES="$GAME_PACKAGES,$PKG"
            fi
        fi
    done
    if [ -z "$GAME_PACKAGES" ]; then
        echo ""
        echo "[信息] 未检测到支持的游戏，未做任何更改。"
        return 1
    fi
    echo ""
    echo "[信息] 已选中包名列表："
    echo "$GAME_PACKAGES"
    return 0
}

apply_driver() {
    echo ""
    echo "========== 应用 Game Driver =========="
    apply_setting "game_driver_opt_in_apps" "$GAME_PACKAGES"
    settings delete global game_driver_opt_out_apps >/dev/null 2>&1
    if [ "$SDK" -ge 31 ]; then
        apply_setting "updatable_driver_production_opt_in_apps" "$GAME_PACKAGES"
        settings delete global updatable_driver_production_opt_out_apps >/dev/null 2>&1
    fi
    echo ""
    echo "========== 验证 =========="
    echo "[GAME DRIVER]"
    settings get global game_driver_opt_in_apps
    if [ "$SDK" -ge 31 ]; then
        echo ""
        echo "[UPDATABLE PRODUCTION DRIVER]"
        settings get global updatable_driver_production_opt_in_apps
    fi
}

render_tuning() {
    log "正在应用渲染 / GPU / CPU 调优..."
    settings put global gfx.disable_frame_pacing 1 >/dev/null 2>&1
    settings put global gfx.swapinterval 0        >/dev/null 2>&1
    cmd device_config put activity_manager max_cached_processes 16 >/dev/null 2>&1
    cmd device_config put activity_manager use_freezer true       >/dev/null 2>&1
    settings put system refresh_rate_policy adaptive              >/dev/null 2>&1
    settings put system refresh_rate_mode 0                       >/dev/null 2>&1
    settings put system display_refresh_rate_mode 0               >/dev/null 2>&1
    settings put system peak_refresh_rate 120                     >/dev/null 2>&1
    settings put system min_refresh_rate 60                       >/dev/null 2>&1
    settings put system enable_optimize_refresh_rate false        >/dev/null 2>&1
    settings put system lockscreen_limit_refresh_rate 0           >/dev/null 2>&1
    settings put system per_app_refresh_rate "com.mobile.legends:120,com.tencent.ig:120" >/dev/null 2>&1
    settings put global thermal_event_log 0                       >/dev/null 2>&1
    settings put global debug.sf.hw 1                             >/dev/null 2>&1
    settings put global debug.sf.vsync_reactor 0                  >/dev/null 2>&1
    settings put global debug.sf.use_buffer_age false             >/dev/null 2>&1
    settings put global debug.sf.late.sf.duration 0               >/dev/null 2>&1
    settings put global debug.sf.early.sf.duration 0              >/dev/null 2>&1
    settings put global force_peak_refresh_rate 0                 >/dev/null 2>&1
    settings put global peak_refresh_rate 0                       >/dev/null 2>&1
    settings put global min_refresh_rate 60                       >/dev/null 2>&1
    settings put global game.dynamic_fps 1                        >/dev/null 2>&1
    settings put global game.dynamic_fps_mode 2                   >/dev/null 2>&1
    settings put global game.min_fps 60                           >/dev/null 2>&1
    settings put global game.max_fps 240                          >/dev/null 2>&1
    settings put global game.performance_level 3                  >/dev/null 2>&1
    settings put global gpu.performance.tuning 1                  >/dev/null 2>&1
    settings put global gpu.frame_pacing 0                        >/dev/null 2>&1
    settings put global scheduler.boost 1                         >/dev/null 2>&1
    settings put global cpu_max_freq.boost 1                      >/dev/null 2>&1
    settings put global thermal_limit.cpu 0                       >/dev/null 2>&1
    settings put global thermal_limit.gpu 0                       >/dev/null 2>&1
    settings put system touch.pressure.scale 0.1                  >/dev/null 2>&1
    settings put system touch.size.scale 0.1                      >/dev/null 2>&1
    settings put global touch.resample 0                          >/dev/null 2>&1
    settings put global device_idle_constants inactive_to 0       >/dev/null 2>&1
    log "渲染调优已应用。"
}

GAME_LIST='
game.revani.racemaxpro
com.hottagames.nte
Nekootan.kfkj
io.supercent.weaponrpg
adventure.rpg.anime.game.vng.ys6
age.of.civilizations2.jakowski.lukasz
air.com.ubisoft.brawl.halla.platform.fighting.action.pvp
brownmonster.app.game.rushrally3
com.AlfaBravo.Combat
com.CarXTech.highWay
com.CarXTech.street
com.ChillyRoom.DungeonShooter
com.EndlessClouds.Treeverse
com.EtherGaming.PocketRogues
com.Flanne.MinutesTillDawn.roguelike.shooting.gp
com.FosFenes.Sonolus
com.GameCoaster.ProtectDungeon
com.HoYoverse.Nap
com.HoYoverse.hkrpgoversea
com.LanPiaoPiao.PlantsVsZombiesRH
com.MOBGames.PoppyMobileChap1
com.OxGames.Pluvia
com.PigeonGames.Phigros
com.PigeonGames.Rizline
com.ProjectMoon.LimbusCompany
com.Psyonix.RL2D
com.RickyG.DONTFORGET
com.RoamingStar.BlueArchive
com.ShinyShoe.MonsterTrain.mtap
com.Shooter.ModernWarfront
com.Shooter.ModernWarship
com.Shooter.ModernWarships
com.Sunborn.SnqxExilium
com.Sunborn.SnqxExilium.Glo
com.TeamCherry.HollowKnight
com.TechTreeGames.TheTower
com.Vince.AlamobileFormula
com.WandaSoftware.TruckersofEurope3
com.Wispwood.ArrowQuest
com.YoStarEN.Arknights
com.YoStarEN.HBR
com.YoStarEN.MahjongSoul
com.YoStarJP.MajSoul
com.YoStar.AetherGazer
com.YostarJP.BlueArchive
com.YoStarJP.Arknights
com.ZeroCastleGameStudioINTL.StrikeBusterPrototype
com.ZeroCastleGameStudio.StrikeBusterPrototype
com.actgames.bbee
com.activision.callofduty.shooter
com.activision.callofduty.warzone
com.albiononline
com.aligames.kuang.kybc
com.aligames.kuang.kybc.huawei
com.alightcreative.motion
com.android.test.uibench
com.andromeda.androbench2
com.and.games505.Terraria
com.archosaur.sea.dr.gp
com.asobimo.toramonline
com.autumn.skullgirls
com.axlebolt.standoff2
com.bairimeng.dmmdzz
com.bandainamcoent.opbrww
com.bandainamcoent.sao
com.bandainamcoent.shinycolorsprism
com.bandainamcoent.tensuramrkww
com.bandainamcoent.ultimateninjastorm
com.bandainamcogames.dbzdokkanww
com.bf.sgs.hdexp.bd
com.bhvr.deadbydaylight
com.bilibiligame.heglgp
com.bilibili.azurlane
com.bilibili.deadcells.mobile
com.bilibili.fatego
com.bilibili.heaven
com.bilibili.priconne
com.bilibili.star.bili
com.bilibili.warmsnow
com.biligamekr.aggp
com.bingkolo.kleins.cn
com.blizzard.diablo.immortal
com.blizzard.wtcg.hearthstone
com.bluepoch.m.en.reverse1999
com.bscotch.crashlands2
com.bushiroad.d4dj
com.bushiroad.en.bangdreamgbp
com.bushiroad.lovelive.schoolidolfestival2
com.carxtech.sr
com.chillyroom.soulknightprequel
com.chucklefish.stardewvalley
com.citra.emu
com.cnvcs.xiangqi
com.com2us.starseedgl.android.google.global.normal
com.companyname.AM2RWrapper
com.criticalforceentertainment.criticalops
com.crunchyroll.princessconnectredive
com.denachina.g13002010
com.dena.a12026801
com.denchi.vtubestudio
com.devsisters.ck
com.dfjz.moba
com.dgames.g15002002
com.dishii.mm
com.dishii.soh
com.dois.greedgame
com.dolphinemu.dolphinemu
com.dragonli.projectsnow.lhm
com.drivezone.car.race.game
com.dts.freefireadv
com.dts.freefiremax
com.dts.freefireth
com.dts.freefireth.huawei
com.dxx.firenow
com.ea.gp.apexlegendsmobilefps
com.ea.gp.fifamobile
com.ea.gp.nfsm
com.emulator.fpse64
com.epicgames.fortnite
com.epicgames.portal
com.epsxe.ePSXe
com.eyougame.msen
com.fantablade.icey
com.farlightgames.igame.gp
com.feralinteractive.gridas
com.firewick.p42.bilibili
com.firsttouchgames.dls7
com.fizzd.connectedworlds
com.futuremark.dmandroid.application
com.gabama.monopostolite
com.gaijingames.wtm
com.gakpopuler.gamekecil
com.gameark.ggplay.lonsea
com.gamedevltd.wwh
com.gameloft.android.ANMP.GloftA9HM
com.gameloft.android.ANMP.GloftMVHM
com.gameloft.android.SAMS.GloftA9SS
com.garena.game.codm
com.garena.game.df
com.garena.game.kgid
com.garena.game.kgtw
com.garena.game.kgvn
com.garena.game.lmjx
com.garena.game.nfsm
com.gbits.funnyfighter.android.overseas
com.gravity.romg
com.gravity.roo.sea
com.gryphline.exastris.gp
com.guigugame.guigubahuang
com.guyou.deadstrike
com.h73.jhqyna
com.halo.windf.hero
com.heavenburnsred
com.hermes.j1game
com.hermes.mk
com.herogame.gplay.magicminecraft.mmorpg
com.hg.cosmicshake
com.hg.lbw
com.hottapkgs.hotta
com.humo.yqqsqz.yw
com.hypergryph.arknights
com.hypergryph.exastris
com.idreamsky.klbqm
com.idreamsky.strinova
com.igg.android.doomsdaylastsurvivors
com.ignm.raspberrymash.jp
com.ilongyuan.implosion
com.infoldgames.infinitynikkien
com.jacksparrow.jpmajiang
com.japan.datealive.gp
com.je.supersus
com.jumpw.mobile300
com.kakaogames.eversoul
com.kakaogames.gdts
com.kakaogames.wdfp
com.kiloo.subwaysurf
com.kog.grandchaseglobal
com.komoe.kmumamusumegp
com.kurogame.aki
com.kurogame.gplay.punishing.grayraven.en
com.kurogame.haru
com.kurogame.haru.bilibili
com.kurogame.haru.hero
com.kurogame.mingchao
com.kurogame.wutheringwaves.global
com.leiting.wf
com.lemcnsun.soultide.android
com.levelinfinite.hotta.gp
com.levelinfinite.sgameGlobal
com.levelinfinite.sgameGlobal.midaspay
com.lilithgames.hgame.cn
com.lilithgame.hgame.gp
com.lilithgame.roc.gp
com.linecorp.LGGRTHN
com.linegames.sl
com.longe.allstarhmt
com.lrgame.dldl.sea
com.madfingergames.legends
com.maleo.bussimulatorid
com.miHoYo.GI.samsung
com.miHoYo.GenshinImpact
com.miHoYo.HSoDv2JPOriginalEx
com.miHoYo.Nap
com.miHoYo.Yuanshen
com.miHoYo.bh3
com.miHoYo.bh3global
com.miHoYo.bh3oversea
com.miHoYo.bh3rdJP
com.miHoYo.bh3.bilibili
com.miHoYo.bh3.mi
com.miHoYo.bh3.uc
com.miHoYo.enterprise.NGHSoD
com.miHoYo.hkrpg
com.miHoYo.ys
com.miHoYo.zenless
com.minidragon.idlefantasy
com.miniworldgame.creata.vn
com.miraclegames.farlight84
com.mobiin.gp
com.mobilechess.gp
com.mobilelegends.hwag
com.mobilelegends.mi
com.mobilelegends.taptest
com.mobile.legends
com.modx.daluandou
com.mojang.hostilegg
com.mojang.minecraftpe
com.mojang.minecraftpe.patch
com.morizero.milthm
com.nanostudios.games.twenty.minutes
com.ncsoft.lineagen
com.nebulajoy.act.dmcpoc.asia
com.nekki.shadowfight
com.nekki.shadowfight3
com.neowizgames.game.browndust2
com.neowiz.game.idolypride.en
com.netease.AVALON
com.netease.EVE
com.netease.aceracer
com.netease.allstar
com.netease.dfjs
com.netease.dunkcd
com.netease.dwrg
com.netease.eve.en
com.netease.frxyna
com.netease.g78na.gb
com.netease.g93na
com.netease.h73hmt
com.netease.h75na
com.netease.hyxd
com.netease.idv
com.netease.jddsaef
com.netease.ko
com.netease.l22
com.netease.lagrange
com.netease.lglr
com.netease.lztgglobal
com.netease.ma84
com.netease.ma100asia
com.netease.moba
com.netease.mrzh
com.netease.newspike
com.netease.nshm
com.netease.nshmhmt
com.netease.onmyoji
com.netease.party
com.netease.partyglobal
com.netease.pes
com.netease.qrsj
com.netease.race
com.netease.racerna
com.netease.sky
com.netease.soulofhunter
com.netease.tj
com.netease.tom
com.netease.wotb
com.netease.wyclx
com.netease.x19
com.netease.yhtj
com.netease.yyslscn
com.netflix.NGP.GTAIIIDefinitiveEdition
com.netflix.NGP.GTASanAndreasDefinitiveEdition
com.netflix.NGP.GTAViceCityDefinitiveEdition
com.netmarble.skiagb
com.netmarble.sololv
com.netmarble.tog
com.nexon.bluearchive
com.nexon.kartdrift
com.nexon.konosuba
com.nexon.mdnf
com.nexon.mod
com.ngame.allstar.eu
com.nianticlabs.monsterhunter
com.nianticproject.ingress
com.noctuagames.android.ashechoes
com.noctua.android.crazyones
com.npixel.GranSagaGB
com.olzhass.carparking.multyplayer
com.oninou.FAPI
com.papegames.infinitynikki
com.papegames.nn4.en
com.pearlabyss.blackdesertm
com.pearlabyss.blackdesertm.gl
com.pinkcore.tkfm
com.plarium.raidlegends
com.playdigious.deadcells.mobile
com.playmini.miniworld
com.play.rosea
com.popcap.pvz
com.primatelabs.geekbench6
com.proximabeta.dn2.global
com.proximabeta.mf.aceforce2
com.proximabeta.mf.liteuamo
com.proximabeta.mf.uamo
com.proximabeta.nikke
com.proxima.dfm
com.prpr.musedash
com.pubg
com.pubg.imobile
com.pubg.krmobile
com.pubg.newstate
com.pwrd.hotta.laohu
com.pwrd.huanta
com.pwrd.opmwsea
com.pwrd.p5x
com.pwrd.persona5x.laohu
com.r2games.myhero.bilibili
com.rayark.cytus2
com.rayark.deemo2
com.rayark.deemoreborn
com.rayark.implosion
com.rayark.sdorica
com.rekoo.pubgm
com.retroarch
com.rinzz.projectmuse
com.riotgames.league.teamfighttactics
com.riotgames.league.teamfighttacticstw
com.riotgames.league.teamfighttacticsvn
com.riotgames.league.wildrift
com.roblox.client
com.roblox.client.vnggames
com.robtopx.geometryjump
com.rockstargames.gta3
com.rockstargames.gta3.de
com.rockstargames.gtasa
com.rockstargames.gtasa.de
com.rockstargames.gtavc
com.rockstargames.gtavc.de
com.rsg.myheroesen
com.sandboxinteractive.albiononline
com.sandboxol.blockymods
com.seasun.jx3
com.seasun.snowbreak.google
com.sega.ColorfulStage.en
com.sega.pjsekai
com.sega.soniccd.classic
com.sgra.dragon
com.shangyoo.neon
com.shatteredpixel.shatteredpixeldungeon
com.shenlan.m.reverse1999
com.silverstarstudio.angellegion
com.smokoko.race
com.sofunny.Sausage
com.soulgamechst.majsoul
com.spaceapegames.beatstar
com.sprduck.garena.vn
com.squareenix.lis
com.starform.metalstorm
com.stove.epic7.google
com.studiobside.CounterSide
com.studiowildcard.wardrumstudios.ark
com.studiowildcard.wardrumstudios.ark.ncr
com.sugarfun.gp.sea.lzgwy
com.sunborn.girlsfrontline.en
com.sunborn.neuralcloud
com.sunborn.neuralcloud.en
com.superb.rhv
com.supercell.boombeach
com.supercell.brawlstars
com.supercell.clashofclans
com.supercell.clashroyale
com.supercell.hayday
com.supercell.squad
com.sybogames.subway.surfers.game
com.sy.dldlhsdj
com.t2ksports.nba2k20and
com.tencent.KiHan
com.tencent.af
com.tencent.baiyeint
com.tencent.hhw
com.tencent.ig
com.tencent.iglite
com.tencent.jkchess
com.tencent.letsgo
com.tencent.lolm
com.tencent.mf.uam
com.tencent.msgame
com.tencent.nba2kx
com.tencent.nfsonline
com.tencent.tmgp.WePop
com.tencent.tmgp.bh3
com.tencent.tmgp.cf
com.tencent.tmgp.cod
com.tencent.tmgp.dfjs
com.tencent.tmgp.dfm
com.tencent.tmgp.dnf
com.tencent.tmgp.dwrg
com.tencent.tmgp.ffom
com.tencent.tmgp.gnyx
com.tencent.tmgp.kr.codm
com.tencent.tmgp.pubgmhd
com.tencent.tmgp.sgame
com.tencent.tmgp.sgamece
com.tencent.tmgp.speedmobile
com.tencent.tmgp.sskeus
com.tencent.tmgp.supercell.boombeach
com.tencent.tmgp.wuxia
com.tencent.tmgp.yys.zqb
com.tencent.rmcn
com.tencent.toaa
com.tgc.sky.android
com.the10tons.dysmantle
com.tinybuildgames.helloneighbor
com.tipsworks.android.pascalswager
com.tipsworks.pascalswager
com.trampolinetales.lbal
com.tumuyan.ncnn.realsr
com.tungsten.fcl
com.cygames.umamusume
com.ubisoft.rainbowsixmobile.r6.fps.pvp.shooter
com.unity.mmd
com.valvesoftware.cswgsm
com.valvesoftware.source
com.vng.mlbbvn
com.vng.pubgmobile
com.vng.speedvn
com.wb.goog.scribblenauts3
com.winlator
com.winlator.cmod
com.ludashi.benchmark
com.wondergames.warpath.gp
com.xd.TLglobal
com.xd.dxlzz.taptap
com.xd.muffin.gp.global
com.xd.rotaeno.googleplay
com.xd.rotaeno.tapcn
com.xd.ssrpgen
com.xd.terraria
com.xd.xdt
com.xindong.torchlight
com.yinhan.hunter
com.yongshi.tenojo
com.yoozoo.jgame.global
com.yoozoo.jgame.us
com.zlongame.mhmnz
com.ztgame.bob
com.ztgame.yyzy
com.zy.wqmt.cn
com.bandainamcoent.dblegends_ww
com.bandainamcoent.idolmaster_gakuen
com.bandainamcoent.imas_millionlive_theaterdays
com.ea.games.r3_row
com.ea.game.pvz2_rfl
com.ea.game.pvz2_row
com.ea.game.pvzfree_row
com.feralinteractive.gridautosport_edition_android
com.miHoYo.bh3oversea_vn
cyou.joiplay.joiplay
hg.toriteling.neetchan
game.qualiarts.idolypride
gplay.punishing.grayraven
id.rj01117883.liomeko
jp.co.bandainamcoent.BNEI0242
jp.co.craftegg.band
jp.co.cygames.princessconnectredive
jp.co.cygames.umamusume
jp.co.koeitecmo.ReslerianaGL
jp.garud.ssimulator
jp.konami.duellinks
jp.konami.masterduel
jp.konami.pesam
jp.pokemon.pokemonunite
jp.goodsmile.touhoulostwordglobal_android
lega.feisl.hhera
me.magnum.melonds.nightly
me.mugzone.emiria
me.pou.app
me.tigerhix.cytoid
minitech.miniworld
moe.low.arc
net.kdt.pojavlaunch
net.kdt.pojavlaunch.debug
net.kdt.pojavlaunch.firefly
net.wargaming.wot.blitz
nlch.game.Imouto
org.citra.emu
org.dolphinemu.dolphinemu
org.flos.phira
org.godotengine.godot4
org.maxbytes.lfs
org.mm.jr
org.mupen64plusae.v3.alpha
org.mupen64plusae.v3.fzurita.pro
org.openttd.sdl
org.ppsspp.ppsspp
org.ppsspp.ppssppgold
org.vita3k.emulator
org.citron.citron_emu
org.sudachi.sudachi_emu.ea
org.uzuy.uzuy_emu.ea
org.yuzu.yuzu_emu
pro.archiemeng.waifu2x
ro.alyn_sampmobile.game
ru.nsu.ccfit.zuev.osuplus
ru.unisamp_mobile.game
sh.ppy.osulazer
skyline.emu
skyline.purple
skynet.cputhrottlingtest
tw.sonet.allbw
tw.sonet.princessconnect
tw.txwy.and.arknights
uk.co.powdertoy.tpt
vng.games.revelation.mobile
www.townofmagic.com
xd.sce.promotion
xyz.aethersx2.android
com.actgames.bbee.gl
com.sunborn.net
'

banner "安装 / 应用"
log "Android : $ANDROID"
log "SDK     : $SDK"
log "EGL/GPU : $GPU"
log "配置档  : $DRIVER_API"

if detect_games; then
    apply_driver
    render_tuning
    echo ""
    echo "========================================"
    echo " 游戏优化 安装完成"
    echo " Android : $ANDROID"
    echo " SDK     : $SDK"
    echo " 配置档  : $DRIVER_API"
    echo "========================================"
    notify "安装成功 - 请检查开发者选项"
else
    notify "未检测到支持的游戏"
fi