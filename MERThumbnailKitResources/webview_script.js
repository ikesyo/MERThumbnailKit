(function(){
    if(!document.getElementById('MERThumbnailKitScript')){
        var sc = document.createElement('script');
        sc.setAttribute('id', 'MERThumbnailKitScript');
        sc.text = (function(){
            var STATE = 'complete',
                _readyStateCompleteURI = 'orgmaestromerthumbnailkit:ready';

            function _onReadyStateChange(e){

                if(e.target.readyState == STATE){
                    document.removeEventListener('readystatechange', _onReadyStateChange);
                    window.location.href = _readyStateCompleteURI;
                }
            }

            document.addEventListener('readystatechange', _onReadyStateChange, false);
        })();
        document.body.appendChild(sc);
    }
})();
