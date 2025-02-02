module CTDirect

using CTBase
using DocStringExtensions
using ADNLPModels               # docp model with AD
using LinearAlgebra             # norm and misc
using HSL

import CTBase: OptimalControlSolution, CTBase   # extended

# other declarations
const matrix2vec = CTBase.matrix2vec

# includes
include("utils.jl")
include("default.jl")
include("problem.jl") # rename as docp.jl ?
include("midpoint.jl")
include("trapeze.jl")
include("solution.jl")
include("solve.jl")

# exports
export available_methods
export is_solvable
export direct_transcription
export set_initial_guess
export export_ocp_solution
export import_ocp_solution
export direct_solve

end
