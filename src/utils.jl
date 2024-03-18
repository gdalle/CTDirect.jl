function get_variable(xu, docp)
    if docp.has_variable
        if docp.variable_dimension == 1
            return xu[end]
        else
            return xu[end-docp.variable_dimension+1:end]
        end
    else
        return Float64[]
    end
end

# return original ocp state
function get_state_at_time_step(xu, docp, i::Int64)
    """
        return
        x(t_i)
    """
    nx = docp.dim_NLP_state
    n = docp.ocp.state_dimension
    N = docp.dim_NLP_steps
    @assert i <= N "trying to get x(t_i) for i > N"
    if n == 1
        return xu[i*nx + 1]
    else
        return xu[i*nx + 1 : i*nx + n]
    end
end

function get_lagrange_cost_at_time_step(xu, docp, i)
    nx = docp.dim_NLP_state
    N = docp.dim_NLP_steps
    @assert i <= N "trying to get lagrange cost at t_i for i > N"
    return xu[(i+1)*nx]
end

function vget_state_at_time_step(xu, docp, i)
    nx = docp.dim_NLP_state
    N = docp.dim_NLP_steps
    @assert i <= N "trying to get x(t_i) for i > N"
    return xu[i*nx + 1 : (i+1)*nx]
end

function get_control_at_time_step(xu, docp, i)
    """
        return
        u(t_i)
    """
    nx = docp.dim_NLP_state
    m = docp.ocp.control_dimension
    N = docp.dim_NLP_steps
    @assert i <= N "trying to get u(t_i) for i > N"
    if m == 1
        return xu[(N+1)*nx + i*m + 1]
    else
        return xu[(N+1)*nx + i*m + 1 : (N+1)*nx + (i+1)*m]
    end
end

function vget_control_at_time_step(xu, docp, i)
    nx = docp.dim_NLP_state
    m = docp.ocp.control_dimension
    N = docp.dim_NLP_steps
    @assert i <= N "trying to get u(t_i) for i > N"
    return xu[(N+1)*nx + i*m + 1 : (N+1)*nx + (i+1)*m]
end

function get_initial_time(xu, docp)
    if docp.has_free_initial_time
        v = get_variable(xu, docp)
        return v[docp.ocp.initial_time]
    else
        return docp.ocp.initial_time
    end
end

function get_final_time(xu, docp)
    if docp.has_free_final_time
        v = get_variable(xu, docp)
        return v[docp.ocp.final_time]
    else
        return docp.ocp.final_time
    end
end

## Initialization for the NLP problem

function set_state_at_time_step!(xu, x_init, docp, i)
    nx = docp.dim_NLP_state
    n = docp.ocp.state_dimension
    N = docp.dim_NLP_steps
    @assert i <= N "trying to set init for x(t_i) with i > N"
    # NB. only set first n components of state variable (nx = n+1 for lagrange cost)
    if n == 1
        xu[i*nx + 1] = x_init[]
    else
        xu[i*nx + 1 : i*nx + n] = x_init
    end
end
    
function set_control_at_time_step!(xu, u_init, docp, i)
    nx = docp.dim_NLP_state
    m = docp.ocp.control_dimension
    N = docp.dim_NLP_steps
    @assert i <= N "trying to set init for u(t_i) with i > N"
    offset = (N+1)*nx
    if m == 1
        xu[offset + i*m + 1] = u_init[]
    else        
        xu[offset + i*m + 1 : offset + i*m + m] = u_init
    end
end

function set_variable!(xu, v_init, docp)
    if docp.variable_dimension == 1
        xu[end] = v_init[]
    else
        xu[end-docp.variable_dimension+1 : end] = v_init
    end
end

function initial_guess(docp)

    # default initialization
    # note: internal variables (lagrange cost, k_i for RK schemes) will keep these default values 
    xu0 = 0.1 * ones(docp.dim_NLP_variables)

    init = docp.NLP_init
    N = docp.dim_NLP_steps
    t0 = get_initial_time(xu0, docp)
    tf = get_final_time(xu0, docp)
    h = (tf - t0) / N 

    # set state / control variables if provided
    for i in 0:N
        ti = t0 + i * h
        if !isnothing(init.state_init(ti))
            set_state_at_time_step!(xu0, init.state_init(ti), docp, i)
        end
        if !isnothing(init.control_init(ti))
            set_control_at_time_step!(xu0, init.control_init(ti), docp, i)
        end

        # set variables if provided
        if !isnothing(init.variable_init)
            set_variable!(xu0, init.variable_init, docp)
        end
    end

    return xu0
end