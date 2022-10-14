// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*

Döviz Swap Nedir?
Tarafların önceden anlaştıkları kurlarla, iki farklı döviz tutarını; 
işlemin yapıldığı tarihte takas ettikleri, işlemin vade tarihinde ise 
ilgili para birimlerini anlaştıkları oran ve şartlarda geri takas ettikleri işlemdir. 

*/

contract SwapContract {
    // eventler daha sonra çağırılmak için kullanılır örn: fronted 
    event Launch(
        // Kullanıcı id'si
        uint id,
        address indexed creator
    );

    event Pledge(uint indexed id, address indexed caller, uint amount, uint day, uint8 pledgerate, uint8 fixrate); 
    
    struct Campaign {
        // kampanya yaratıcısı
        address creator;
        // tahahhut
        uint pledged;
        // Kazanç
        uint winnings;
        // Hedefe ulaşıldıysa ve tokenslar talet edildiyse bool true döndürür.
        bool claimed;
    }

    // Oluşturulan toplam kampanya sayısı.
    uint public count;

    // // id'den Kampanyaya eşleme ve çağırma - görüntüleme
    mapping(uint => Campaign) public campaigns;
    // Kampanya kimliğinden eşleme => taahhüt veren => taahhüt edilen miktar
    mapping(uint => mapping(address => uint)) public pledgedAmount;
    mapping(uint => mapping(address => uint)) public winningsAmount;

    function launch() external {
       // require kontrolleri
        
        count += 1;
        campaigns[count] = Campaign({
            // creator : gönderen kişinin adresi
            creator : msg.sender,
            pledged : 0,
            winnings : 0,
            claimed : false 
        });

        emit Launch(count, msg.sender);
   }

   function pledge(uint _id, uint _amount, uint _day, uint8 _fixrate, uint8 _pledgerate) external {
       // _fixrate = anlık sabit kur
       // _pledgerate = tahhahüt edilen kur
        require( _pledgerate >= _fixrate , "anlik kur , tahhahut edilen kurdan dusuk veya esit oldugundan isleminizi gerceklestiremiyoruz.");
        Campaign storage campaign = campaigns[_id];

        campaign.pledged += _amount;
        campaign.winnings += _amount + _day*(_pledgerate - _fixrate);

        pledgedAmount[_id][msg.sender] += _amount;
        winningsAmount[_id][msg.sender] += (_amount + _day*(_pledgerate - _fixrate)) - _amount;

        emit Pledge(_id , msg.sender , _amount , _day , _fixrate , _pledgerate);
    }

    modifier onlyCount {
        require(count > 0 , "Count > 0");
        _;
    }

}