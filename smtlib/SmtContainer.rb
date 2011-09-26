#
# SMT-LIB List Class
#
class SmtList
	@@Prefix = 'List'

	def initialize (*dim, &type)
		@type = type.call
		@suffix = self.object_id
		@dim = []

		dim.each do |d|
			if d.instance_of? Range
				@dim << d
			elsif not d.instance_of? Fixnum
				raise "dimension must be an integer! (#{d})"
			elsif d < 1
				raise "dimension must be a natural number! (#{d})"
			else
				@dim << (0...d)
			end
		end

		bind self.variables(@dim).inject(Hash.new){|s, v| s[v] = @type; s}
	end

	def [] (*id)
		ret = self.variables id
		(ret.size == 1) ? ret.shift : ret
	end

	def variables (id)
		if id.size != @dim.size
			raise "wrong number of indexs (#{id.size} for #{@dim.size})"
		end

		ret = SmtVariableArray.new
		ret << "#{@@Prefix}_#{@suffix}"

		id.each_with_index do |d, i|
			if not @dim[i].includeR? d
				raise "out of range (#{d} for #{@dim[i]})"
			end

			if d.instance_of? Range
				ret.map!{|pre| d.to_a.map{|v| "#{pre}_#{v}"}}.flatten!
			else
				ret.map!{|pre| "#{pre}_#{d}"}
			end
		end

		ret
	end
end

