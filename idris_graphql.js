#!/usr/bin/env node
"use strict";

(function(){

const $JSRTS = {
    throw: function (x) {
        throw x;
    },
    Lazy: function (e) {
        this.js_idris_lazy_calc = e;
        this.js_idris_lazy_val = void 0;
    },
    force: function (x) {
        if (x === undefined || x.js_idris_lazy_calc === undefined) {
            return x
        } else {
            if (x.js_idris_lazy_val === undefined) {
                x.js_idris_lazy_val = x.js_idris_lazy_calc()
            }
            return x.js_idris_lazy_val
        }
    },
    prim_strSubstr: function (offset, len, str) {
        return str.substr(Math.max(0, offset), Math.max(0, len))
    }
};
$JSRTS.os = require('os');
$JSRTS.fs = require('fs');
$JSRTS.prim_systemInfo = function (index) {
    switch (index) {
        case 0:
            return "node";
        case 1:
            return $JSRTS.os.platform();
    }
    return "";
};
$JSRTS.prim_writeStr = function (x) { return process.stdout.write(x) }
$JSRTS.prim_readStr = function () {
    var ret = '';
    var b = new Buffer(1024);
    var i = 0;
    while (true) {
        $JSRTS.fs.readSync(0, b, i, 1)
        if (b[i] == 10) {
            ret = b.toString('utf8', 0, i);
            break;
        }
        i++;
        if (i == b.length) {
            var nb = new Buffer(b.length * 2);
            b.copy(nb)
            b = nb;
        }
    }
    return ret;
};



function $partial_5_6$io_95_bind(x1, x2, x3, x4, x5){
    return (function(x6){
        return io_95_bind(x1, x2, x3, x4, x5, x6);
    });
}

function $partial_3_4$io_95_pure(x1, x2, x3){
    return (function(x4){
        return io_95_pure(x1, x2, x3, x4);
    });
}

function $partial_0_2$prim_95__95_strCons(){
    return (function(x1){
        return (function(x2){
            return prim_95__95_strCons(x1, x2);
        });
    });
}

function $partial_5_6$Prelude__Basics____(x1, x2, x3, x4, x5){
    return (function(x6){
        return Prelude__Basics____(x1, x2, x3, x4, x5, x6);
    });
}

function $partial_1_2$Client__require(x1){
    return (function(x2){
        return Client__require(x1, x2);
    });
}

function $partial_0_1$Prelude__Strings__unlines_39_(){
    return (function(x1){
        return Prelude__Strings__unlines_39_(x1);
    });
}

function $partial_0_1$Prelude__Strings__unpack(){
    return (function(x1){
        return Prelude__Strings__unpack(x1);
    });
}

function $partial_0_1$Schema___123_formatComp_95_0_125_(){
    return (function(x1){
        return Schema___123_formatComp_95_0_125_(x1);
    });
}

function $partial_0_1$Main___123_main_95_0_125_(){
    return (function(x1){
        return Main___123_main_95_0_125_(x1);
    });
}

function $partial_3_4$Client___123_request_95_0_125_(x1, x2, x3){
    return (function(x4){
        return Client___123_request_95_0_125_(x1, x2, x3, x4);
    });
}

function $partial_0_1$Prelude__Strings___123_unlines_95_0_125_(){
    return (function(x1){
        return Prelude__Strings___123_unlines_95_0_125_(x1);
    });
}

function $partial_0_1$Schema___123_wrap_95_0_125_(){
    return (function(x1){
        return Schema___123_wrap_95_0_125_(x1);
    });
}

function $partial_0_1$Main___123_main_95_1_125_(){
    return (function(x1){
        return Main___123_main_95_1_125_(x1);
    });
}

function $partial_2_3$Client___123_request_95_1_125_(x1, x2){
    return (function(x3){
        return Client___123_request_95_1_125_(x1, x2, x3);
    });
}

function $partial_0_1$Prelude__Strings___123_unlines_95_1_125_(){
    return (function(x1){
        return Prelude__Strings___123_unlines_95_1_125_(x1);
    });
}

function $partial_0_1$Main___123_main_95_2_125_(){
    return (function(x1){
        return Main___123_main_95_2_125_(x1);
    });
}

function $partial_0_1$Main___123_main_95_3_125_(){
    return (function(x1){
        return Main___123_main_95_3_125_(x1);
    });
}

function $partial_0_1$Main___123_main_95_4_125_(){
    return (function(x1){
        return Main___123_main_95_4_125_(x1);
    });
}

function $partial_0_1$Main___123_main_95_5_125_(){
    return (function(x1){
        return Main___123_main_95_5_125_(x1);
    });
}

function $partial_6_7$$_1_io_95_bind(x1, x2, x3, x4, x5, x6){
    return (function(x7){
        return $_1_io_95_bind(x1, x2, x3, x4, x5, x6, x7);
    });
}

const $HC_0_0$MkUnit = ({type: 0});
function $HC_2_1$Prelude__List___58__58_($1, $2){
    this.type = 1;
    this.$1 = $1;
    this.$2 = $2;
}

function $HC_2_0$Builtins__MkPair($1, $2){
    this.type = 0;
    this.$1 = $1;
    this.$2 = $2;
}

function $HC_4_0$Schema__MkQueryField($1, $2, $3, $4){
    this.type = 0;
    this.$1 = $1;
    this.$2 = $2;
    this.$3 = $3;
    this.$4 = $4;
}

const $HC_0_0$Prelude__List__Nil = ({type: 0});
const $HC_0_1$Prelude__Basics__No = ({type: 1});
const $HC_0_0$Prelude__Maybe__Nothing = ({type: 0});
function $HC_1_0$Schema__Qu($1){
    this.type = 0;
    this.$1 = $1;
}

function $HC_2_1$Prelude__Strings__StrCons($1, $2){
    this.type = 1;
    this.$1 = $1;
    this.$2 = $2;
}

const $HC_0_0$Prelude__Strings__StrNil = ({type: 0});
const $HC_0_1$Schema__Triv = ({type: 1});
const $HC_0_0$Prelude__Basics__Yes = ({type: 0});
// io_bind

function io_95_bind($_0_e, $_1_e, $_2_e, $_3_e, $_4_e, w){
    return $_2_io_95_bind($_0_e, $_1_e, $_2_e, $_3_e, $_4_e, w)($_3_e(w));
}

// io_pure

function io_95_pure($_0_e, $_1_e, $_2_e, w){
    return $_2_e;
}

// prim__strCons

function prim_95__95_strCons($_0_op, $_1_op){
    return (($_0_op)+($_1_op));
}

// Prelude.List.++

function Prelude__List___43__43_($_0_e, $_1_e, $_2_e){
    
    if(($_1_e.type === 1)) {
        return new $HC_2_1$Prelude__List___58__58_($_1_e.$1, Prelude__List___43__43_(null, $_1_e.$2, $_2_e));
    } else {
        return $_2_e;
    }
}

// Prelude.Basics..

function Prelude__Basics____($_0_e, $_1_e, $_2_e, $_3_e, $_4_e, x){
    return $_3_e($_4_e(x));
}

// Schema.formatComp

function Schema__formatComp($_0_e, $_1_e, $_2_e, $_3_e){
    
    
    let $cg$3 = null;
    if(($_3_e.$3.type === 0)) {
        $cg$3 = "";
    } else {
        $cg$3 = ("(" + (Schema__formatArgs_58_formatArgs_39__58_1(null, $_3_e.$3) + ")"));
    }
    
    const $cg$5 = $_3_e.$4;
    let $cg$4 = null;
    if(($cg$5.type === 0)) {
        $cg$4 = Schema__wrap(Schema__formatComps(null, null, null, $cg$5.$1));
    } else {
        $cg$4 = $HC_0_0$Prelude__List__Nil;
    }
    
    return Prelude__List___43__43_(null, new $HC_2_1$Prelude__List___58__58_(($_3_e.$2 + $cg$3), $HC_0_0$Prelude__List__Nil), Prelude__Functor__Prelude__List___64_Prelude__Functor__Functor_36_List_58__33_map_58_0(null, null, $partial_0_1$Schema___123_formatComp_95_0_125_(), $cg$4));
}

// Schema.formatComps

function Schema__formatComps($_0_e, $_1_e, $_2_e, $_3_e){
    
    if(($_3_e.type === 1)) {
        return Prelude__List___43__43_(null, Schema__formatComp(null, null, null, $_3_e.$1), Schema__formatComps(null, null, null, $_3_e.$2));
    } else {
        return $HC_0_0$Prelude__List__Nil;
    }
}

// SchemaTests.inception

function SchemaTests__inception(){
    return new $HC_1_0$Schema__Qu(new $HC_2_1$Prelude__List___58__58_(new $HC_4_0$Schema__MkQueryField($HC_0_0$Prelude__Maybe__Nothing, "Movie", new $HC_2_1$Prelude__List___58__58_(new $HC_2_0$Builtins__MkPair("title", "Inception"), $HC_0_0$Prelude__List__Nil), new $HC_1_0$Schema__Qu(new $HC_2_1$Prelude__List___58__58_(new $HC_4_0$Schema__MkQueryField($HC_0_0$Prelude__Maybe__Nothing, "releaseDate", $HC_0_0$Prelude__List__Nil, $HC_0_1$Schema__Triv), new $HC_2_1$Prelude__List___58__58_(new $HC_4_0$Schema__MkQueryField($HC_0_0$Prelude__Maybe__Nothing, "actors", $HC_0_0$Prelude__List__Nil, new $HC_1_0$Schema__Qu(new $HC_2_1$Prelude__List___58__58_(new $HC_4_0$Schema__MkQueryField($HC_0_0$Prelude__Maybe__Nothing, "name", $HC_0_0$Prelude__List__Nil, $HC_0_1$Schema__Triv), $HC_0_0$Prelude__List__Nil))), $HC_0_0$Prelude__List__Nil)))), $HC_0_0$Prelude__List__Nil));
}

// Main.main

function Main__main(){
    return $partial_5_6$io_95_bind(null, null, null, $partial_5_6$io_95_bind(null, null, null, $partial_0_1$Main___123_main_95_0_125_(), $partial_0_1$Main___123_main_95_1_125_()), $partial_0_1$Main___123_main_95_5_125_());
}

// Client.request

function Client__request($_0_e, $_1_e, $_2_e, $_3_e, $_4_e){
    return $partial_5_6$io_95_bind(null, null, null, $partial_1_2$Client__require("graphql-request"), $partial_2_3$Client___123_request_95_1_125_($_3_e, $_4_e));
}

// Client.require

function Client__require($_0_e, w){
    return (require(($_0_e)));
}

// Prelude.Strings.unlines

function Prelude__Strings__unlines(){
    return $partial_5_6$Prelude__Basics____(null, null, null, $partial_0_1$Prelude__Strings___123_unlines_95_0_125_(), $partial_5_6$Prelude__Basics____(null, null, null, $partial_0_1$Prelude__Strings__unlines_39_(), $partial_0_1$Prelude__Strings___123_unlines_95_1_125_()));
}

// Prelude.Strings.unlines'

function Prelude__Strings__unlines_39_($_0_e){
    
    if(($_0_e.type === 1)) {
        return Prelude__List___43__43_(null, $_0_e.$1, new $HC_2_1$Prelude__List___58__58_("\n", Prelude__Strings__unlines_39_($_0_e.$2)));
    } else {
        return $HC_0_0$Prelude__List__Nil;
    }
}

// Prelude.Strings.unpack

function Prelude__Strings__unpack($_0_e){
    let $cg$1 = null;
    if((Decidable__Equality__Decidable__Equality___64_Decidable__Equality__DecEq_36_Bool_58__33_decEq_58_0((!(!(!($_0_e == "")))), true).type === 1)) {
        $cg$1 = $HC_0_0$Prelude__Strings__StrNil;
    } else {
        $cg$1 = new $HC_2_1$Prelude__Strings__StrCons($_0_e[0], $_0_e.slice(1));
    }
    
    
    if(($cg$1.type === 1)) {
        return new $HC_2_1$Prelude__List___58__58_($cg$1.$1, Prelude__Strings__unpack($cg$1.$2));
    } else {
        return $HC_0_0$Prelude__List__Nil;
    }
}

// Schema.wrap

function Schema__wrap($_0_e){
    return Prelude__List___43__43_(null, new $HC_2_1$Prelude__List___58__58_("{", $HC_0_0$Prelude__List__Nil), Prelude__List___43__43_(null, Prelude__Functor__Prelude__List___64_Prelude__Functor__Functor_36_List_58__33_map_58_0(null, null, $partial_0_1$Schema___123_wrap_95_0_125_(), $_0_e), new $HC_2_1$Prelude__List___58__58_("}", $HC_0_0$Prelude__List__Nil)));
}

// Schema.{formatComp_0}

function Schema___123_formatComp_95_0_125_($_5_in){
    return ("  " + $_5_in);
}

// Main.{main_0}

function Main___123_main_95_0_125_($_0_in){
    return $JSRTS.prim_writeStr("hello idris-graphql!\n");
}

// Client.{request_0}

function Client___123_request_95_0_125_($_0_in, $_3_e, $_4_e, $_1_in){
    let $cg$1 = null;
    if(($_4_e.type === 0)) {
        $cg$1 = Schema__wrap(Schema__formatComps(null, null, null, $_4_e.$1));
    } else {
        $cg$1 = $HC_0_0$Prelude__List__Nil;
    }
    
    return ((function(c,url,q){ c.request(url,q).then(data => console.log(JSON.stringify(data, null, 2))); })(($_0_in),($_3_e),(Prelude__Strings__unlines()($cg$1))));
}

// Prelude.Strings.{unlines_0}

function Prelude__Strings___123_unlines_95_0_125_($_0_in){
    return Prelude__Foldable__Prelude__List___64_Prelude__Foldable__Foldable_36_List_58__33_foldr_58_0(null, null, $partial_0_2$prim_95__95_strCons(), "", $_0_in);
}

// Schema.{wrap_0}

function Schema___123_wrap_95_0_125_($_0_in){
    return ("  " + $_0_in);
}

// Main.{main_1}

function Main___123_main_95_1_125_($_1_in){
    return $partial_3_4$io_95_pure(null, null, $HC_0_0$MkUnit);
}

// Client.{request_1}

function Client___123_request_95_1_125_($_3_e, $_4_e, $_0_in){
    return $partial_3_4$Client___123_request_95_0_125_($_0_in, $_3_e, $_4_e);
}

// Prelude.Strings.{unlines_1}

function Prelude__Strings___123_unlines_95_1_125_($_1_in){
    return Prelude__Functor__Prelude__List___64_Prelude__Functor__Functor_36_List_58__33_map_58_0(null, null, $partial_0_1$Prelude__Strings__unpack(), $_1_in);
}

// Main.{main_2}

function Main___123_main_95_2_125_($_3_in){
    const $cg$2 = SchemaTests__inception();
    let $cg$1 = null;
    if(($cg$2.type === 0)) {
        $cg$1 = Schema__wrap(Schema__formatComps(null, null, null, $cg$2.$1));
    } else {
        $cg$1 = $HC_0_0$Prelude__List__Nil;
    }
    
    return $JSRTS.prim_writeStr((Prelude__Strings__unlines()($cg$1) + "\n"));
}

// Main.{main_3}

function Main___123_main_95_3_125_($_5_in){
    return $partial_3_4$io_95_pure(null, null, $HC_0_0$MkUnit);
}

// Main.{main_4}

function Main___123_main_95_4_125_($_6_in){
    return Client__request(null, null, null, "https://api.graph.cool/simple/v1/movies", SchemaTests__inception());
}

// Main.{main_5}

function Main___123_main_95_5_125_($_2_in){
    return $partial_5_6$io_95_bind(null, null, null, $partial_5_6$io_95_bind(null, null, null, $partial_0_1$Main___123_main_95_2_125_(), $partial_0_1$Main___123_main_95_3_125_()), $partial_0_1$Main___123_main_95_4_125_());
}

// Decidable.Equality.Decidable.Equality.Bool implementation of Decidable.Equality.DecEq, method decEq

function Decidable__Equality__Decidable__Equality___64_Decidable__Equality__DecEq_36_Bool_58__33_decEq_58_0($_0_e, $_1_e){
    
    if($_1_e) {
        
        if($_0_e) {
            return $HC_0_0$Prelude__Basics__Yes;
        } else {
            return $HC_0_1$Prelude__Basics__No;
        }
    } else {
        
        if($_0_e) {
            return $HC_0_1$Prelude__Basics__No;
        } else {
            return $HC_0_0$Prelude__Basics__Yes;
        }
    }
}

// Prelude.Foldable.Prelude.List.List implementation of Prelude.Foldable.Foldable, method foldr

function Prelude__Foldable__Prelude__List___64_Prelude__Foldable__Foldable_36_List_58__33_foldr_58_0($_0_e, $_1_e, $_2_e, $_3_e, $_4_e){
    
    if(($_4_e.type === 1)) {
        return $_2_e($_4_e.$1)(Prelude__Foldable__Prelude__List___64_Prelude__Foldable__Foldable_36_List_58__33_foldr_58_0(null, null, $_2_e, $_3_e, $_4_e.$2));
    } else {
        return $_3_e;
    }
}

// Prelude.Functor.Prelude.List.List implementation of Prelude.Functor.Functor, method map

function Prelude__Functor__Prelude__List___64_Prelude__Functor__Functor_36_List_58__33_map_58_0($_0_e, $_1_e, $_2_e, $_3_e){
    
    if(($_3_e.type === 1)) {
        return new $HC_2_1$Prelude__List___58__58_($_2_e($_3_e.$1), Prelude__Functor__Prelude__List___64_Prelude__Functor__Functor_36_List_58__33_map_58_0(null, null, $_2_e, $_3_e.$2));
    } else {
        return $HC_0_0$Prelude__List__Nil;
    }
}

// {io_bind_0}

function $_0_io_95_bind($_0_e, $_1_e, $_2_e, $_3_e, $_4_e, w, $_0_in){
    return $_4_e($_0_in);
}

// {runMain_0}

function $_0_runMain(){
    return $JSRTS.force(Main__main()(null));
}

// {io_bind_1}

function $_1_io_95_bind($_0_e, $_1_e, $_2_e, $_3_e, $_4_e, w, $_0_in){
    return $_0_io_95_bind($_0_e, $_1_e, $_2_e, $_3_e, $_4_e, w, $_0_in)(w);
}

// {io_bind_2}

function $_2_io_95_bind($_0_e, $_1_e, $_2_e, $_3_e, $_4_e, w){
    return $partial_6_7$$_1_io_95_bind($_0_e, $_1_e, $_2_e, $_3_e, $_4_e, w);
}

// Schema.formatArgs, formatArgs'

function Schema__formatArgs_58_formatArgs_39__58_1($_0_e, $_1_e){
    
    if(($_1_e.type === 1)) {
        
        if(($_1_e.$2.type === 0)) {
            const $cg$6 = $_1_e.$1;
            return ($cg$6.$1 + (": " + ("\"" + ($cg$6.$2 + "\""))));
        } else {
            const $cg$4 = $_1_e.$1;
            let $cg$3 = null;
            $cg$3 = ($cg$4.$1 + (": " + ("\"" + ($cg$4.$2 + "\""))));
            return ($cg$3 + (", " + Schema__formatArgs_58_formatArgs_39__58_1(null, $_1_e.$2)));
        }
    } else {
        return "";
    }
}


$_0_runMain();
}.call(this))