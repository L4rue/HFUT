function searchProblem(prob) {
    var CryptoJS = require("crypto-js");
    var problem = prob;
    re = new RegExp("\\'","g");
    let title = problem.replace(re,'');

    var key = '39383033327777772e313530732e636e';
    var iv = '38383332307777772e313530732e636e';
    key = CryptoJS.enc.Hex.parse(key)
    iv = CryptoJS.enc.Hex.parse(iv)
    var enc = CryptoJS.AES.encrypt(title ,key, {'iv':iv})

    var enced = enc.ciphertext.toString()
    return enced 
}