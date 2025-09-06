/**
 * @license
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @author
 * gigonzalezs [gb@autanalabs.com]
 */

import { Agentlet } from '../lib/agentlet-1.0.0.js';

/**
 * Web Component TicTacToe
 *
 * Esta clase representa un agente de Tic Tac Toe que extiende de Agentlet.
 * Gestiona el estado del tablero, procesa instrucciones desde el shell,
 * y permite la interacción del usuario a través de clics en la UI.
 *
 * Métodos clave:
 * - getBoard(): Devuelve el estado del tablero como un arreglo plano.
 * - clearBoard(): Limpia el tablero y devuelve el nuevo estado.
 * - placeMove({row, col}): Intenta colocar un movimiento 'O' en la celda especificada.
 * - render(): Renderiza el tablero y captura interacciones del usuario ('X').
 */
class TicTacToe extends Agentlet {

    static get agentletId() {
        return {
            "manifestVersion": "1.1.0-mini",
            "name": "Tic Tac Toe",
            "version": "0.1.1",
            "groupId": "io.ggobuk",
            "artifactId": "builtin",
            "tagName": "tic-tac-toe",
        }
    }

    constructor() {
        super();
        this._board = [
            ['', '', ''],
            ['', '', ''],
            ['', '', '']
        ];
    }

    /**
     * Devuelve el estado actual del tablero en forma de arreglo de objetos.
     * Cada objeto incluye fila, columna y el valor de la celda.
     *
     * @returns {Array} Estado del tablero.
     */
    getBoard() {
        const boardArray = [];
        for (let row = 0; row < 3; row++) {
            for (let col = 0; col < 3; col++) {
                boardArray.push({
                    row,
                    col,
                    cell: this._board[row][col]
                });
            }
        }
        return boardArray;
    }

    /**
     * Tool invocda por LLM: Limpia el tablero reiniciando todas las celdas.
     * 
     * @returns {Object} Respuesta de éxito con el nuevo estado del tablero.
     */
    clearBoard() {
        this._board = [
            ['', '', ''],
            ['', '', ''],
            ['', '', '']
        ];
        this.render();
        return {
            status: 'OK',
            message: 'Tablero borrado. Se devuelve estado actual del tablero.',
            response: this.getBoard()
        }
    }

    /**
     * Tool invocda por LLM: Intenta colocar un símbolo 'O' en la celda indicada.
     * 
     * @param {Object} param0 - Coordenadas de la celda.
     * @param {number} param0.row - Índice de fila.
     * @param {number} param0.col - Índice de columna.
     * @returns {Object} Respuesta con estado 'OK' o 'ERROR' dependiendo del resultado.
     */
    placeMove({ row, col }) {
        if (this._board[row][col] === '') {
            this._board[row][col] = 'O';
            this.render();

            return {
                status: 'OK',
                message: 'Movimiento ejecutado. Se devuelve estado actual del tablero.',
                response: this.getBoard()
            }
        } else {
            return {
                status: 'ERROR',
                message: `ERROR: La posición row=${row}, col=${col} ya estaba ocupada por el jugador '${this._board[row][col]}'. Intenta de nuevo.`
            }
        }
    }

    /**
     * Procesa llamadas a herramientas desde el shell.
     *
     * @param {string} toolName - Nombre de la herramienta invocada.
     * @param {any} params - Parámetros asociados a la herramienta.
     * @returns {Object|Array|undefined} Respuesta según la herramienta procesada.
     */
    onToolCall(toolName, params) {
        switch (toolName) {
            case 'placeMove':
                if (params && Array.isArray(params)) {
                    const [row, col] = params;
                    return this.placeMove({ row, col });
                }
                if (params && typeof params === 'object') {
                    const { row, col } = params;
                    return this.placeMove({ row, col });
                }
                break;
            case 'clearBoard':
                return this.clearBoard();
            default:
                console.warn(`Tool no reconocida: ${toolName}`);
                break;
        }
    }

    /**
     * Maneja mensajes recibidos desde el shell que no son llamadas a herramientas.
     *
     * @param {string} message - Mensaje crudo recibido.
     */
    onMessageFromShell(message) {
        console.log(`tic-tac-toe: message received: ${message}.`);
    }

    /**
     * Renderiza el tablero de juego en el shadow DOM.
     * Cada celda vacía puede ser clicada por el usuario, lo que marca una 'X' y notifica al shell.
     * También se invoca internamente por otras herramientas como clearBoard() o placeMove() para actualizar la vista.
     */
    render() {
        this.shadowRoot.innerHTML = `
            <style>
            .agentlet-wrapper {
                    display: flex;
                    justify-content: center;
                    margin-top: 24px;
                    
                }
                .agentlet-frame {
                    display: inline-block;
                    padding: 16px 24px;
                    border: 2px solid #d9d9d9;
                    border-radius: 10px;
                    background: #fff;
                    box-shadow: 0 6px 20px rgba(0,0,0,0.08);
                }
                .board {
                    display: grid;
                    grid-template-columns: repeat(3, 60px);
                    gap: 5px;
                    width: max-content;
                }
                .cell {
                    width: 60px;
                    height: 60px;
                    font-size: 24px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    background-color: #f0f0f0;
                    cursor: pointer;
                    border: 1px solid #ccc;
                }
            </style>
            <div class="agentlet-wrapper">
                <div class="agentlet-frame">
                    <div class="board">
                        ${this._board.map((row, rowIndex) =>
                        row.map((cell, colIndex) => `
                                <div class="cell" data-row="${rowIndex}" data-col="${colIndex}">
                            ${cell}
                        </div>
                        `).join('')
                        ).join('')}
                    </div>
                </div>
            </div>
        `;

        this.shadowRoot.querySelectorAll('.cell').forEach(cell => {
            cell.addEventListener('click', () => {
                const row = parseInt(cell.getAttribute('data-row'));
                const col = parseInt(cell.getAttribute('data-col'));
                if (this._board[row][col] === '') {
                    this._board[row][col] = 'X';
                    const response = {
                        type: 'message',
                        message: `usuario jugó en (${row}, ${col})`
                    };
                    Agentlet.shell.sendMessageToShell(JSON.stringify(response));
                    this.render();
                }
            });
        });
    }
}


/**
 * Registro del agente TicTacToe como Web Component personalizado.
 * Esto permite que el shell lo reconozca y lo utilice dinámicamente
 * a través de su manifest.
 */
Agentlet.register(TicTacToe);

