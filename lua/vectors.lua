local vector = {}

function vector.crear()
    return {0, 0, 0}
end

function vector.dot(vec1, vec2)
    return vec1[1] * vec2[1] + vec1[2] * vec2[2] + vec1[3] * vec2[3]
end

function vector.normalize(vec)
    local longitud = (vec[1]^2 + vec[2]^2 + vec[3]^2)^0.5
    if longitud == 0 then
        return {0, 0, 0}
    else
        return {vec[1]/longitud, vec[2]/longitud, vec[3]/longitud}
    end
end

function vector.mat3_mul(mat1, mat2)
    local matriz = { {0,0,0}, {0,0,0}, {0,0,0} }
    for i = 1, 3 do
        for j = 1, 3 do
            matriz[i][j] = mat1[i][1] * mat2[1][j]
                        + mat1[i][2] * mat2[2][j]
                        + mat1[i][3] * mat2[3][j]
        end
    end
    return matriz
end

function vector.mat3_vec(vec, mat)
    return {
        mat[1][1]*vec[1] + mat[1][2]*vec[2] + mat[1][3]*vec[3],
        mat[2][1]*vec[1] + mat[2][2]*vec[2] + mat[2][3]*vec[3],
        mat[3][1]*vec[1] + mat[3][2]*vec[2] + mat[3][3]*vec[3],
    }
end

function vector.rota_x(angle)
    local cosi, sinu = math.cos(angle), math.sin(angle)
    return {
        {1, 0, 0},
        {0, cosi, -sinu},
        {0, sinu, cosi}
    }
end

function vector.rota_y(angle)
    local cosi, sinu = math.cos(angle), math.sin(angle)
    return {
        {cosi, 0, sinu},
        {0, 1, 0},
        {-sinu, 0, cosi}
    }
end

function vector.rota_z(angle)
    local cosi, sinu = math.cos(angle), math.sin(angle)
    return {
        {cosi, -sinu, 0},
        {sinu, cosi, 0},
        {0, 0, 1}
    }
end

function vector.rotacion_completa(anglex, angley, anglez)
    local rotx, roty, rotz = vector.rota_x(anglex), vector.rota_y(angley), vector.rota_z(anglez)
    return vector.mat3_mul(rotz, vector.mat3_mul(roty, rotx))
end

function vector.transpose(M)
    return {
        { M[1][1], M[2][1], M[3][1] },
        { M[1][2], M[2][2], M[3][2] },
        { M[1][3], M[2][3], M[3][3] },
    }
end

return vector
