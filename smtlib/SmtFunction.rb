#
# 引数の変数定義の評価
#
def def_vars_evaluate (vars = {})
	ret = {}
	vars.each do |v, type|
		if v.instance_of? SmtSymbolArray
			v.expand.each do |vv|
				ret[vv] = type
			end
		else
			ret[v] = type
		end
	end
	return ret
end

#
# 変数の宣言 (bind)
#
def bind (variables = {})
	var = variables.map{|k, v| "(declare-fun #{k} () #{v})"}
	var.each{|v| SmtSystem.define_var v}
	var.join("\n")
end

#
# 新しいSMT関数の定義
#
def define (name, rtype, vars={}, &block)
	vars = def_vars_evaluate(vars)

	eval <<-METHOD
		def #{name} (*params)
			params = def_vars_evaluate(params.flatten).keys

			if params.size != #{vars.size}
				raise "wrong number of elements (\#{params.size} for #{vars.size})" 
			end

			"(#{name} \#{params.join(' ')})"
		end
	METHOD

	vars = vars.map{|k, v| "(#{k} #{v})"}.join('')
	expr = block.call

	SmtSystem.define_func "(define-fun #{name} (#{vars}) #{rtype} #{expr})"
end

#
# 全ての式を and で連結する
#
def and_all (*exprs)
	exprs = exprs.flatten
	raise "required at least 2 expressions" if exprs.size < 2

	"(and #{exprs.join(" ")})"
end

#
# 全ての式を or で連結する
#
def or_all (*exprs)
	exprs = exprs.flatten
	raise "required at least 2 expressions" if exprs.size < 2

	"(or #{exprs.join(" ")})"
end

#
# exists formula method
#
def exists (variables={}, &block)
	vars = def_vars_evaluate(variables).map{|k, v| "(#{k} #{v})"}.join('')
	expr = block.call
	"(exists (#{vars}) #{expr})"
end

#
# forall formula method
#
def forall (variables={}, &block)
	vars = def_vars_evaluate(variables).map{|k, v| "(#{k} #{v})"}.join('')
	expr = block.call
	"(forall (#{vars}) #{expr})"
end

