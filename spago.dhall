{ name = "purescript-lua-console"
, dependencies = [ "lua-effect", "lua-prelude" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
, backend =
    ''
    pslua \
    --foreign-path . \
    --ps-output output \
    --lua-output-file dist/Effect_Console.lua \
    --entry Effect.Console
    ''
}
