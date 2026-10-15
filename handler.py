# Handler do RunPod Serverless — remove o fundo com rembg (modelo BiRefNet).
# Recebe uma imagem em base64 e devolve o PNG sem fundo, também em base64.
import runpod, base64, io
from rembg import remove, new_session
from PIL import Image

# Carrega o modelo UMA vez (fica na memória da GPU entre requisições).
session = new_session("birefnet-general")

def handler(event):
    inp = event.get("input", {}) or {}
    b64 = inp.get("image_base64")
    if not b64:
        return {"error": "Envie 'image_base64' no input."}
    # Aceita com ou sem o prefixo "data:image/...;base64,"
    if "," in b64[:40]:
        b64 = b64.split(",", 1)[1]
    try:
        data = base64.b64decode(b64)
        img = Image.open(io.BytesIO(data)).convert("RGBA")
    except Exception as e:
        return {"error": "Imagem invalida: " + str(e)}

    out = remove(img, session=session)   # <- recorte acontece aqui
    buf = io.BytesIO()
    out.save(buf, format="PNG")
    return {"image_base64": base64.b64encode(buf.getvalue()).decode("utf-8")}

runpod.serverless.start({"handler": handler})
