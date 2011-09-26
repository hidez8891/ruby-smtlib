#
# Operator Alias
#
OperatorAlias = {
	'+'  => 'add',
	'-'  => 'sub',
	'*'  => 'mul',
	'&'  => 'and',
	'|'  => 'or',
	'<'  => 'le',
	'<=' => 'leq',
	'>'  => 'ge',
	'>=' => 'geq',
	'==' => 'eq',
	'!=' => 'neq',
	'>>' => 'imp'
}

#
# basic type
#
Bool = :Bool
Real = :Real
Int  = :Int

#
# Logic Type
#
class Logic
	(
		Bool,Int,Real,
		Linear,NonLinear,
		Quantifed,NoQuantifed,
		Array
	) = (1..8).to_a.map{|d| 2**d}

	def self.get (logic)
		# type = ''
		# type << 'QF_' if logic & self::Quantifed == 0
		# type << 'AUF' if logic & self::Array     != 0
		# type << 'N'   if logic & self::NonLinear != 0
		# type << 'L'   if logic & self::NonLinear == 0
		# type << 'I'   if logic & self::Int       != 0
		# type << 'R'   if logic & self::Real      != 0

		# if logic & self::Quantifed == 0 && logic & self::Bool != 0
			# type = 'QF_UF'
		# end

		# type
		"AUFLIRA"
	end
end

