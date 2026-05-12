#Requires AutoHotkey v2.0

class TravelHistory {
    __New(limit := 10, filePath := "history.txt") {
        this.limit := limit
        this.filePath := filePath
    }

    getAll() {
        destinations := []
        if !FileExist(this.filePath) {
            return destinations
        }
        loop read, this.filePath {
            line := Trim(A_LoopReadLine)
            if (line != "") {
                destinations.Push(line)
            }
        }
        return destinations
    }

    add(destination) {
        destinations := this.getAll()

        ; Remove duplicata para mover ao topo
        i := 1
        while i <= destinations.Length {
            if (destinations[i] = destination) {
                destinations.RemoveAt(i)
            } else {
                i++
            }
        }

        ; Insere no início (mais recente primeiro)
        destinations.InsertAt(1, destination)

        ; Aplica o limite
        while destinations.Length > this.limit {
            destinations.Pop()
        }

        this.save(destinations)
    }

    save(destinations) {
        if FileExist(this.filePath) {
            FileDelete(this.filePath)
        }
        content := ""
        for dest in destinations {
            content .= dest . "`n"
        }
        if (content != "") {
            FileAppend(content, this.filePath)
        }
    }
}
