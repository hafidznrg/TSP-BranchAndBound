# Author
# Nama      : Hafidz Nur Rahman Ghozali
# NIM       : 13520117
# Problem   : Travelling Salesman Problem dengan Algoritma Branch & Bound menggunakan metode Matriks Ongkos Tereduksi

# Kelas Node memiliki atribut rute yang dilalui, cost yang dibutuhkan, dan matriks yang telah direduksi
class Node
    attr_accessor :rute, :cost, :matriks

    def initialize(rute, cost, matriks)
        @rute = rute
        @cost = cost
        @matriks = matriks
    end

    # mengembalikan true jika node merupakan leaf
    def isGoalNode()
        return @rute.length == @matriks.length
    end
end

# Fungsi untuk mereduksi matriks
# Mengembalikan matriks setelah direduksi dan cost untuk reduksi matriks
def reduksiMatriks(matriks)
    cost = 0
    inf = Float::INFINITY
    row = matriks.length - 1
    col = matriks[0].length - 1

    # pencarian per baris
    for i in 0..row
        found = false
        min = inf
        for j in 0..col
            if matriks[i][j] == 0
                found = true
                break
            end
            if !found && matriks[i][j] != inf && matriks[i][j] < min
                min = matriks[i][j]
            end
        end

        if !found && min != inf
            cost += min
            for j in 0..col
                matriks[i][j] -= min
            end
        end
    end

    # pencarian per kolom
    for j in 0..col
        found = false
        min = inf
        for i in 0..row
            if matriks[i][j] == 0
                found = true
                break
            end
            if !found && matriks[i][j] != inf && matriks[i][j] < min
                min = matriks[i][j]
            end
        end

        if !found && min != inf
            cost += min
            for i in 0..row
                matriks[i][j] -= min
            end
        end
    end

    return matriks, cost
end

# Prosedur untuk mencetak matriks
def printMatriks(matriks)
    matriks.each do |row|
        row.each do |col|
            print "#{col} "
        end
        puts
    end
end

# Fungsi untuk membuat salinan matriks
def copyMatriks(matriks)
    res = []
    matriks.each do |row|
        rowTemp = []
        row.each do |col|
            rowTemp.push(col)
        end
        res.push(rowTemp)
    end
    return res
end

# Fungsi utama untuk menyelesaikan TSP
# Mengembalikan sebuah goal node
def solve(matriks, start)
    inf = Float::INFINITY
    # Reduce Matriks pertama
    reduceMat, cost = reduksiMatriks(matriks)
    
    # Buat node awal
    node = Node.new([start], cost, reduceMat)

    antrian = []
    antrian.push(node)
    antrian.sort_by! { |node| node.cost }

    # Perulangan BFS
    while antrian.length > 0
        current = antrian.shift
        parent = current.rute[-1]

        # jika node sekarang merupakan leaf/goal node
        if current.isGoalNode
            # hapus node di dalam antrian yang memiliki cost lebih besar dari goal saat ini
            antrian.delete_if { |node| node.cost > current.cost }

            # keluarkan node
            return current
        end

        # jika bukan goal node, cari node yang bertetangga dan masukkan ke antrian
        for child in 0..current.matriks.length - 1
            if current.matriks[parent][child] != inf && current.rute.include?(child) == false
                rute = current.rute.dup + [child]
                cost = current.cost + current.matriks[parent][child]
                mat = copyMatriks(current.matriks)

                # mengubah semua nilai pada baris parent menjadi inf
                for i in 0..mat.length - 1
                    mat[parent][i] = inf
                end
                
                # mengubah semua nilai pada baris kolom child menjadi inf
                for j in 0..mat[0].length - 1
                    mat[j][child] = inf
                end

                # mengubah mat[child][start] menjadi inf
                mat[child][start] = inf

                # menghitung matriks reduksi dan cost yang dibutuhkan
                matRes, costRes = reduksiMatriks(mat)

                # menambahkan node baru ke dalam antrian
                node = Node.new(rute, cost + costRes, matRes)
                antrian.push(node)
                antrian.sort_by! { |node| node.cost }
            end
        end
    end
end

# Fungsi untuk membaca matriks dari file
# Mengembalikan matriks hasil bacaan
def readFile(file)
    inf = Float::INFINITY
    matriks = []
    File.open(file, "r") do |f|
        f.each_line do |line|
            temp = []
            split = line.split(" ")
            split.each do |s|
                if s == "inf"
                    temp.push(inf)
                else
                    temp.push(s.to_i)
                end
            end
            matriks.push(temp)
        end
    end
    return matriks
end

# Fungsi yang berinteraksi dengan user
def main()
    print "Masukkan nama file matriks: "
    file = gets.chomp
    matriks = []
    
    # Membaca file
    if (!File.exist?(file))
        puts "File tidak ditemukan"
    else 
        matriks = readFile(file)
        puts "Matriks Ketetanggaan:"
        printMatriks(matriks)
        puts "\nIngin memulai dari node berapa? (Node dimulai dari angka 1)"
        print "Node "
        start = gets.chomp.to_i - 1
        result = solve(matriks, start)

        puts "\nRute yang dilalui:"
        result.rute.each do |node|
            print "Node #{node + 1} -> "
        end
        puts "Node #{start + 1}"

        puts "Cost yang dibutuhkan : #{result.cost}"
    end
end

# Menjalankan program
main()