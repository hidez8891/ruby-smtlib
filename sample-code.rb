$LOAD_PATH.push("#{File.dirname(__FILE__)}")
require 'smtlib/SmtLib.rb'

#非プロセスID
NonPID = -1

#プロセスの数
P = 2

#遷移回数
Step = 40

#最大待機時間
MaxReqTime = 100.0

#各ロケーション
class Loc
	(Init, Req, Wait, Cs) = Array(1..4)
end

#添字
S = 0 #source
D = 1 #distination

#時間遷移
define :Delay, Bool, {
	:pre[P] => Real, :next[P] => Real
} {
	exists ({:d => Real}) {
		and_all(
			:d > 0.0 ,
			:next[0..P-1] == :pre[0..P-1] + :d ,
		)
	}
}

#離散遷移1
define :T1, Bool, {
	:l[P,2] => Int , :x[P,2] => Real ,:pid[P] => Int
} {
	expr1 = []

	(0..P-1).each do |k|
		expr2 = []

		#現ロケーション
		expr2.push :l[k,S] == Loc::Init

		#ガード条件
		expr2.push :pid[S] == NonPID

		#リセット条件
		expr2.push :x[k,D] == 0.0

		#次ロケーション
		expr2.push :l[k,D] == Loc::Req
		expr2.push :x[k,D] <= MaxReqTime

		#残りは変わらない (d != k)
		(0..P-1).to_a.select{|d| d != k}.map do |d|
			expr2.push :l[d,D] == :l[d,S]
			expr2.push :x[d,D] == :x[d,S]
		end
		#pidも変わらない
		expr2.push :pid[D] == :pid[S]

		#連言接続
		expr1.push and_all expr2
	end

	#選言接続
	or_all expr1
}

#離散遷移2
define :T2, Bool, {
	:l[P,2] => Int , :x[P,2] => Real ,:pid[P] => Int
} {
	expr1 = []

	(0..P-1).each do |k|
		expr2 = []

		#現ロケーション
		expr2.push :l[k,S] == Loc::Req

		#ガード条件

		#リセット条件
		expr2.push :x[k,D] == 0.0
		expr2.push :pid[D] == k

		#次ロケーション
		expr2.push :l[k,D] == Loc::Wait

		#残りは変わらない (d != k)
		(0..P-1).to_a.select{|d| d != k}.map do |d|
			expr2.push :l[d,D] == :l[d,S]
			expr2.push :x[d,D] == :x[d,S]
		end

		#連言接続
		expr1.push and_all expr2
	end

	#選言接続
	or_all expr1
}

#離散遷移3a
define :T3a, Bool, {
	:l[P,2] => Int , :x[P,2] => Real ,:pid[P] => Int
} {
	expr1 = []

	(0..P-1).each do |k|
		expr2 = []

		#現ロケーション
		expr2.push :l[k,S] == Loc::Wait

		#ガード条件
		expr2.push :pid[S] == NonPID

		#リセット条件
		expr2.push :x[k,D] == 0.0

		#次ロケーション
		expr2.push :l[k,D] == Loc::Req
		expr2.push :x[k,D] <= MaxReqTime

		#残りは変わらない (d != k)
		(0..P-1).to_a.select{|d| d != k}.map do |d|
			expr2.push :l[d,D] == :l[d,S]
			expr2.push :x[d,D] == :x[d,S]
		end
		#pidも変わらない
		expr2.push :pid[D] == :pid[S]

		#連言接続
		expr1.push and_all expr2
	end

	#選言接続
	or_all expr1
}

#離散遷移3b
define :T3b, Bool, {
	:l[P,2] => Int , :x[P,2] => Real ,:pid[P] => Int
} {
	expr1 = []

	(0..P-1).each do |k|
		expr2 = []

		#現ロケーション
		expr2.push :l[k,S] == Loc::Wait

		#ガード条件
		expr2.push :pid[S] == k
		expr2.push :x[k,S] > MaxReqTime

		#リセット条件

		#次ロケーション
		expr2.push :l[k,D] == Loc::Cs

		#残りは変わらない (d != k)
		(0..P-1).to_a.select{|d| d != k}.map do |d|
			expr2.push :l[d,D] == :l[d,S]
			expr2.push :x[d,D] == :x[d,S]
		end
		#pidも変わらない
		expr2.push :pid[D] == :pid[S]

		#連言接続
		expr1.push and_all expr2
	end

	#選言接続
	or_all expr1
}

#離散遷移4
define :T4, Bool, {
	:l[P,2] => Int , :x[P,2] => Real ,:pid[P] => Int
} {
	expr1 = []

	(0..P-1).each do |k|
		expr2 = []

		#現ロケーション
		expr2.push :l[k,S] == Loc::Cs

		#ガード条件

		#リセット条件
		expr2.push :pid[D] == NonPID

		#次ロケーション
		expr2.push :l[k,D] == Loc::Init

		#残りは変わらない (d != k)
		(0..P-1).to_a.select{|d| d != k}.map do |d|
			expr2.push :l[d,D] == :l[d,S]
			expr2.push :x[d,D] == :x[d,S]
		end

		#連言接続
		expr1.push and_all expr2
	end

	#選言接続
	or_all expr1
}

#変数宣言
ck  = SmtList.new(P, 2*Step+1){Real}
loc = SmtList.new(P,   Step+1){Int}
pid = SmtList.new(     Step+1){Int}

#初期設定
assert and_all(ck[0..P-1,  0] == 0.0)
assert and_all(loc[0..P-1, 0] == Loc::Init)
assert pid[0] == NonPID

#遷移を書く
(0..Step-1).each do |k|
	k1 = k
	k2 = 2*k

	#時間遷移
	assert Delay(ck[0..1, k2], ck[0..1, k2+1])

	#離散遷移
	assert or_all(
		T1( loc[0..1, k1+0..k1+1], ck[0..1, k2+1..k2+2], pid[k1+0..k1+1]) ,
		T2( loc[0..1, k1+0..k1+1], ck[0..1, k2+1..k2+2], pid[k1+0..k1+1]) ,
		T3a(loc[0..1, k1+0..k1+1], ck[0..1, k2+1..k2+2], pid[k1+0..k1+1]) ,
		T3b(loc[0..1, k1+0..k1+1], ck[0..1, k2+1..k2+2], pid[k1+0..k1+1]) ,
		T4( loc[0..1, k1+0..k1+1], ck[0..1, k2+1..k2+2], pid[k1+0..k1+1])
	)
end

#検証条件
#同じロケーション => Loc::Csでは無い
(0..Step-1).each do |k|
	(0..P-1).each do |s1|
		(1..P-1).each do |s2|
			assert (loc[s1, k] == loc[s2, k]) >> (loc[s1, k] != Loc::Cs)
		end
	end
end

#設定
SmtSystem.option({
	'print-success' => false ,
	'produce-models' => true
})
SmtSystem.logic(
	Logic::Real | Logic::Int | Logic::Quantifed | Logic::NonLinear | Logic::Array
)

#出力
SmtSystem.print
puts "(check-sat)"
puts "(exit)"
# open('| z3 -smt2 -in', 'r+') {|z3|
	# SmtSystem.print z3
	# #puts z3.gets

	# z3.puts "(check-sat)"
	# puts z3.gets

	# z3.puts "(exit)"
# }

