$LOAD_PATH.push("#{File.dirname(__FILE__)}")
require "SmtConfig.rb"
require "SmtBase.rb"
require "SmtSymbol.rb"
require "SmtFunction.rb"
require "SmtSystem.rb"
require "SmtContainer.rb"

class Range
	def includeR? (other)
		if other.instance_of? Range
			return false if self.first > other.first

			if other.exclude_end?
				return self.end >= other.end
			else
				return self.end >  other.end if self.exclude_end?
				return self.end >= other.end if not self.exclude_end?
			end
		else
			self.include? other
		end
	end
end

class Fixnum
	include SmtLibNumeric
end

class Float
	include SmtLib
end

class String
	include SmtLib
end

class Symbol
	include SmtLib
end

