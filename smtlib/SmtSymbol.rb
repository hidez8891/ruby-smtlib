#
# Symbol Array
# generated from Symbol
#
class SmtSymbolArray
	def initialize (prefix, indexs)
		@prefix = prefix
		@indexs = indexs

		OperatorAlias.each do |ope, as|
			eval <<-METHOD
				def #{ope} (other)
					self.evaluate #{ope} other
				end
			METHOD
		end
	end

	# require
	#  :x[1]    = x_1
	#  :x[1, 2] = x_1_2
	#  :x[1..2] = [x_1, x_2]
	def evaluate
		ret = SmtVariableArray.new
		ret << "#{@prefix}"

		@indexs.each do |v|
			if v.instance_of? Range
				ret.map!{|pre| v.to_a.map{|d| "#{pre}_#{d}"}}.flatten!
			else
				ret.map!{|pre| "#{pre}_#{v}"}
			end
		end

		return (ret.size == 1) ? ret.shift : ret
	end

	# require
	#  :x[1]    = [x_0]
	#  :x[1, 2] = [x_0_0, x_0_1]
	#  :x[1..2] = [x_1, x_2]
	def expand
		ret = SmtVariableArray.new
		ret << "#{@prefix}"

		@indexs.each do |v|
			if v.instance_of? Range
				ret.map!{|pre| v.to_a.map{|d| "#{pre}_#{d}"}}.flatten!
			else
				ret.map!{|pre| (0...v).to_a.map{|d| "#{pre}_#{d}"}}.flatten!
			end
		end

		return ret
	end

	def to_s
		self.evaluate
	end
end

#
# Variable Array
# defined operator (to SMT string)
#
class SmtVariableArray < Array
	def initialize
		super

		OperatorAlias.each do |ope, as|
			eval <<-METHOD
				def #{ope} (other)
					if other.instance_of? SmtSymbolArray
						other = other.evaluate
					end

					if other.instance_of? Array
						if self.size != other.size
							raise "wrong number of elements (\#{other.size} for \#{self.size})" 
						end

						self.zip(other).map{|v| v[0] #{ope} v[1]}
					else
						self.map{|v| v #{ope} other}
					end
				end
			METHOD
		end
	end

end

#
# Symbol (redefined)
# operator [] -> SmtSymbolArray
#
class Symbol
	def [] (*index)
		SmtSymbolArray.new(self.to_s, index)
	end
end

