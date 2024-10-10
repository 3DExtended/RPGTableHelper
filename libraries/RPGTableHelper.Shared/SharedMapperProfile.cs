using AutoMapper;
using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer
{
    public class SharedMapperProfile : Profile
    {
        public SharedMapperProfile()
        {
            CreateOptionMapForType<bool>();
            CreateOptionMapForType<long>(); // TODO add tests
            CreateOptionMapForType<double>();
            CreateOptionMapForType<float>();
            CreateOptionMapForType<char>(); // TODO add tests
            CreateOptionMapForType<int>(); // TODO add tests
            CreateOptionMapForType<DateOnly>();
            CreateOptionMapForType<TimeOnly>(); // TODO add tests
            CreateOptionMapForType<DateTime>(); // TODO add tests
            CreateOptionMapForType<DateTimeOffset>(); // TODO add tests

            CreateMap<string?, Option<string>>().ConvertUsing((tmid, _) => Option.From(tmid));
            CreateMap<Option<string>, string?>()
                .ConvertUsing((tmid) => (tmid.IsNone ? null : tmid.Get()));

            CreateMap<string, Option<string>>().ConvertUsing((tmid, _) => Option.From(tmid));
            CreateMap<Option<string>, string>()
                .ConvertUsing((tmid) => (tmid.IsNone ? default(string)! : tmid.Get()));
        }

        private void CreateOptionMapForType<T>()
            where T : struct
        {
            CreateMap<T?, Option<T>>().ConvertUsing((tmid, _) => Option.From(tmid));
            CreateMap<Option<T>, T?>()
                .ConvertUsing((tmid) => (T?)(tmid.IsNone ? null : tmid.Get()));
        }
    }
}
