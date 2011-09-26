#
# SMT-LIB System Class
#
class SmtSystem
	@@logic = 0
	@@options = {}
	@@functions = []
	@@variables = []
	@@exprs = []

	def self.logic (logic)
		@@logic = Logic.get(logic)
	end

	def self.option (param = {})
		param.each do |k, v|
			@@options[k] = v
		end
		str_options param
	end

	def self.define_func (expr)
		@@functions << expr
		expr
	end

	def self.define_var (expr)
		@@variables << expr
		expr
	end

	def self.assert (expr)
		@@exprs << expr
		expr
	end

	def self.str_options (param = {})
		r = []
		param.each do |k, v|
			r << "(set-option :#{k} #{v})"
		end
		r.join("\n")
	end

	def self.print (io = STDOUT)
		io.puts "(set-logic #{@@logic})"
		io.puts '(set-info :smt-lib-version 2.0)'
		io.puts str_options @@options

		@@functions.each do |v|
			io.puts v
		end

		@@variables.each do |v|
			io.puts v
		end

		@@exprs.each do |v|
			io.puts "(assert #{v})"
		end
	end
end


#
# alias function
#
def assert (expr)
	SmtSystem.assert expr
end

