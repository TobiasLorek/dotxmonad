import qualified Data.Map as M
import XMonad
import XMonad.Actions.TopicSpace
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Spacing(spacing)
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import qualified XMonad.StackSet as W
import System.IO

grey = "%839497"
lightGrey = "%637477"

myTopics :: [Topic]
myTopics = 
    [ "raytracer"
    , "xmonad"
    ]

xmonadUrls =
    [ "https://wiki.haskell.org/Xmonad/Config_archive/Template_xmonad.hs_(0.9)"
    , "http://hackage.haskell.org/package/xmonad-contrib-0.15/docs/XMonad-Doc-Extending.html"
    ]

raytracerUrl = "https://github.com/ssloy/tinyraytracer/wiki/Part-1:-understandable-raytracing"

myTopicConfig :: TopicConfig
myTopicConfig = def
    { topicDirs = M.fromList 
        [ ("raytracer", "~/Projects/raytracer")
        , ("xmonad",    "~/.xmonad/")
        ]
    , defaultTopicAction = const $ spawnShell >*> 3
    , defaultTopic = "xmonad"
    , topicActions = M.fromList 
        [ ("raytracer",  spawnShell)
        , ("xmonad",     spawnShell >> openBrowserMulti xmonadUrls)
        ]

    }

-- extend your keybindings
myKeys conf@XConfig{modMask=modm} =
  [ ((mod4Mask              , xK_n     ), spawnShell) -- %! Launch terminal
  , ((mod4Mask              , xK_a     ), currentTopicAction myTopicConfig)
  {- more  keys ... -}
  ]

goto :: Topic -> X()
goto = switchTopic myTopicConfig


openBrowser :: String -> X()
openBrowser url = spawn $ "qutebrowser -R " ++ url

openBrowserMulti :: [String] -> X()
openBrowserMulti = openBrowser . unwords

spawnShellIn :: Dir -> X()
spawnShellIn dir = spawn $ "urxvt -cd " ++ dir

spawnShell :: X()
spawnShell = currentTopicDir myTopicConfig >>= spawnShellIn

myConfig = do
    checkTopicConfig myTopics myTopicConfig

    spawn $ "setxkbmap -layout gb,se -option 'grp:win_space_toggle';" ++
        "feh --no-fehbg --bg-fill ~/Bilder/wallpaper/sea.jpg;"

    xmproc <- spawnPipe "xmobar"

    return $ def
        { manageHook = manageDocks <+> manageHook def
        , workspaces = myTopics
        , layoutHook = avoidStruts 
            $ spacing 30
            $ layoutHook def
        , terminal = "rxvt"
        , borderWidth = 0
        , normalBorderColor = lightGrey
        , focusedBorderColor = lightGrey
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock; xset dpms force off")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
        , ((mod4Mask, xK_d), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
        , ((mod4Mask .|. shiftMask, xK_q), kill)
        ]

main = xmonad =<< myConfig
