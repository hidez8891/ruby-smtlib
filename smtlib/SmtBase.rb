#
# SMT-LIB Base Module
#
module SmtLibBase
	def smt_add (other)
		"(+ #{self} #{other})"
	end
	def smt_sub (other)
		"(- #{self} #{other})"
	end
	def smt_mul (other)
		"(* #{self} #{other})"
	end
	def smt_and (other)
		"(and #{self} #{other})"
	end
	def smt_or (other)
		"(or #{self} #{other})"
	end
	def smt_le (other)
		"(< #{self} #{other})"
	end
	def smt_leq (other)
		"(<= #{self} #{other})"
	end
	def smt_ge (other)
		"(> #{self} #{other})"
	end
	def smt_geq (other)
		"(>= #{self} #{other})"
	end
	def smt_eq (other)
		"(= #{self} #{other})"
	end
	def smt_neq (other)
		"(distinct #{self} #{other})"
	end
	def smt_imp (other)
		"(=> #{self} #{other})"
	end
end

#
# SMT-LIB Module
# operator overwrite
#
module SmtLib
	include SmtLibBase

	def self.included (mod)
		OperatorAlias.each do |k, v|
			mod.class_eval "alias #{k} smt_#{v}"
		end
	end
end

#
# SMT-LIB Numeric Module
# operator overwrite
#
module SmtLibNumeric
	include SmtLibBase

	def self.included (mod)
		OperatorAlias.each do |k, v|
			mod.class_eval <<-METHOD
				def smt_num_#{v} (other)
					if other.is_a? Numeric
						_#{v} other
					else
						smt_#{v} other
					end
				end
			METHOD

			mod.class_eval "alias _#{v} #{k}"
			mod.class_eval "alias #{k} smt_num_#{v}"
		end

		mod.class_eval "alias _to_s to_s"
		mod.class_eval "alias to_s smt_num_to_s"
	end

	def smt_num_to_s
		if self < 0
			"(- #{self.abs._to_s})"
		else
			self._to_s
		end
	end
end

