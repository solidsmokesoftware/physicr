
## Decision to use a Tuple or a Position from shapes.cr for the key?
## Keys should be immutable, shapes should be movable
## But converting from pos -> tuple for working with the spatial hash might be expensive?
## Something to test for

require "./pairlist"

class SpaceData(T)
end


class SpaceList(T) < SpaceData(T)
    property grid : PairList(Int32, T)

    def initialize
        @grid = PairList(Int32, T).new
    end

    def has(key : Int32)
        @grid.has key
    end

    def has!(key : Int32)
        @grid.has! key
    end

    def add(key : Int32, value : T)
        @grid.add key, value
    end

    def get(key : Int32)
        @grid.get key
    end

    def get!(index : Int32)
        @grid.get! index
    end

    def get?(key : Int32)
        @grid.get key
    end

    def set(key : Int32, value : T)
        @grid.set key, value
    end

    def set!(index : Int32, value : T)
        @grid.set! index, value
    end

    def del(key : Int32)
        @grid.del key
    end

    def del!(index : Int32)
        @grid.del! index
    end
end

class SpaceZone(T) < SpaceData(T)
    property size : Int32

    def initialize(@size)   
    end

    def scale(x : Int32, y : Int32)
        { (x // @size), (y // @size) }
    end

    #Finds the localtion of value anywhere in the grid
    def has(v : T)
        @grid.each do |b|
            h = has b[0], v
            if h
                return h
            end
        end
    end

    # Has a bucket x, y
    def has(x : Int32, y : Int32)
        has scale(x, y)
    end

    # Has a bucket k
    def has(k : Tuple(Int32, Int32))
        if @grid.has_key? k
            true
        else
            false
        end
    end

        # Returns if a value if in a bucket x, y
    def has(x : Int32, y : Int32, v : T)
        k = scale x, y
        has k, v
    end

    # Returns if a value is in a bucket k
    def has(k : Tuple(Int32, Int32), v : T)
        get(k).index { |i| i == v }
    end

    # Check and add a value to a bucket x, y
    def add(x : Int32, y : Int32, v : T)
        k = scale x, y
        add k, v
    end

    # Check and add a value to a bucket k
    def add(k : Tuple(Int32, Int32), v : T)
        if !has k
            add! k
        end
        add! k, v
    end

    # Add a value directly to a bucket x, y
    def add!(x : Int32, y : Int32, v : T)
        k = scale x, y
        add! k
    end

    # Add a value directly to a bucket k
    def add!(k : Tuple(Int32, Int32), v : T)
        @grid[k] << v
    end

    # Add a bucket directly to the grid x, y
    def add!(x : Int32, y : Int32)
        k = scale x, y
        add! k
    end

    # Add a bucket directly to the grid k
    def add!(k : Tuple(Int32, Int32))
        @grid[k] = Array(T).new
    end
    
    # Check and get all items from a bucket x, y
    def get(x : Int32, y : Int32)
        k = scale x, y
        get k
    end

    # Check and get all items from a bucket k
    def get(k : Tuple(Int32, Int32))
        if !has k
            add! k
        end
        get! k
    end

    # Directly get all items from a bucket x, y
    def get!(x : Int32, y : Int32)
        k = scale x, y
        get! k
    end

    # Directly get all items from a bucket k
    def get!(k : Tuple(Int32, Int32))
        @grid[k]
    end

    # Get all items *near* a bucket x, y
    def get(x : Int32, y : Int32, d : Int32)
        k = scale x, y
        get k d
    end

    # Get all items *near* a bucket k
    def get(k : Tuple(Int32, Int32), d : Int32)
        x_min = k[0] - d
        x_max = k[0] + d
        x_rng = x_min..x_max

        y_min = k[1] - d
        y_max = k[1] + d
        y_rng = y_min..y_max

        a = Array(T).new
        x.times do |x|
            y.times do |y|
                a += get(scale(x, y))
            end
        end
        a
    end

    # Check, delete, and return a bucket x, y
    def del(x : Int32, y : Int32)
        k = scale x, y
        del k
    end

    # Check, delete, and return a bucket k
    def del(k : Tuple(Int32, Int32))
        if has k
            a = get! k
            del! k
        end
        a
    end

    # Directly delete a bucket x, y
    def del!(x : Int32, y : Int32)
        k = scale x, y
        del! k
    end

    # Directly delete a bucket k
    def del!(k : Tuple(Int32, Int32))
        @grid.delete(k)
    end

    #Check and delete a value from a bucket x, y
    def del(x : Int32, y : Int32, v : T)
        k = scale x, y
        del k, v
    end

    #Check and delete a value from a bucket k
    def del(k : Tuple(Int32, Int32), v : T)
        a = get k
        a.delete(v)
    end

    # Directly delete a value from a bucket x, y
    def del!(x : Int32, y : Int32, v : T)
        k = scale x, y
        del! k, v
    end

    # Directly delete a value from a bucket k
    def del!(k : Tuple(Int32, Int32), v : T)
        @grid[k].delete(v)
    end
        
end


class SpaceGrid(T) < SpaceZone(T)
    property grid : Array(Array(Array(T)))

    def initialize(s : Int32)
        super s
        @grid = Array(Array(Array(T))).new
    end
end


class SpaceHash(T) < SpaceZone(T)
    property grid : Hash(Tuple(Int32, Int32), Array(T))
    
    def initialize(s : Int32)
        super s
        @grid = Hash(Tuple(Int32, Int32), Array(T)).new
    end
end
