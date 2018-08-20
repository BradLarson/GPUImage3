/** A photo filter based on Photoshop action by Miss Etikate:
 http://miss-etikate.deviantart.com/art/Photoshop-Action-15-120151961
 */

public class MissEtikateFilter: LookupFilter {
    public override init() {
        super.init()
        
        ({lookupImage = PictureInput(imageName:"lookup_miss_etikate.png")})()
    }
}
