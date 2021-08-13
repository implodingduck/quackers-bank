function ClassyImage ( {src, alt } ) {


    return (<div style={ { textAlign: "center", width: "100%" }}>
         
        <div className="blurme img-fluid" style={{ width: "100%", textAlign: "center", backgroundImage: "url('"+src+"')", backgroundBlendMode: "screen" }}>
            <img src={src} className="img-fluid" alt="I am sorry, this image is not actually visible" />
        </div>
        <img src={src} className="img-fluid" alt={alt} title={alt} style={ { position: "absolute", top: 0, left: 0, right: 0, marginLeft: "auto", marginRight: "auto", textAlign: "center" }} />
       
        
        
    </div>)
}

export default ClassyImage;